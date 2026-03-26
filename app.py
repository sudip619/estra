import os
import json
import jwt
from flask import Flask, request, jsonify, g, Response
from flask_cors import CORS
from dotenv import load_dotenv
from datetime import datetime
from supabase import create_client, Client
from groq import Groq

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# --- Initialize Supabase ---
try:
    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
    if not supabase_url or not supabase_key:
        raise ValueError("Supabase URL or Key missing in env variables.")
    supabase: Client = create_client(supabase_url, supabase_key)
except Exception as e:
    print(f"Error initializing Supabase client: {e}")
    supabase = None

# --- Initialize Groq ---
try:
    groq_api_key = os.environ.get("GROQ_API_KEY")
    if not groq_api_key:
        raise ValueError("GROQ_API_KEY missing in env variables.")
    groq = Groq(api_key=groq_api_key)
except Exception as e:
    print(f"Error initializing Groq client: {e}")
    groq = None

# --- Authentication Middleware ---
@app.before_request
def before_request_func():
    # Handle CORS preflight
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        }
        return Response(status=204, headers=headers)

    g.current_user = None
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith("Bearer "):
        return

    token_value = auth_header.split(" ", 1)[1]
    jwt_secret = os.getenv("SUPABASE_JWT_SECRET")
    if not jwt_secret:
        print("CRITICAL ERROR: SUPABASE_JWT_SECRET not set!")
        return

    try:
        payload = jwt.decode(token_value, jwt_secret, algorithms=["HS256"])
        user_id = payload.get("sub")
        if not user_id:
            return

        # Ensure user exists in Supabase
        res = supabase.table("profiles").select("*").eq("id", user_id).single().execute()
        if not res.data:
            # Create profile if not exists
            supabase.table("profiles").insert({"id": user_id, "profile_data": {}}).execute()

        g.current_user = {"id": user_id}

    except Exception as e:
        print(f"JWT Authentication Error: {e}")


# --- Profile Endpoints ---
@app.route('/api/profile', methods=['GET'])
def get_user_profile():
    if not g.current_user:
        return jsonify({'message': 'Authentication required.'}), 401

    res = supabase.table("profiles").select("*").eq("id", g.current_user["id"]).single().execute()
    profile = res.data or {}
    return jsonify(profile), 200


@app.route('/api/profile', methods=['POST'])
def update_user_profile():
    if not g.current_user:
        return jsonify({'message': 'Authentication required.'}), 401

    data = request.get_json()
    new_profile_data = data.get("profile_data")
    if new_profile_data is None:
        return jsonify({'message': 'Invalid data.'}), 400

    supabase.table("profiles").update({"profile_data": new_profile_data}).eq("id", g.current_user["id"]).execute()
    return jsonify({'message': 'Profile updated successfully!', 'profile_data': new_profile_data}), 200


# --- Mood Endpoints ---
@app.route('/api/mood', methods=['POST'])
def log_mood():
    if not g.current_user:
        return jsonify({'message': 'Authentication required.'}), 401

    data = request.get_json()
    mood = data.get("mood")
    if not mood:
        return jsonify({'message': 'Mood data is required.'}), 400

    supabase.table("mood_logs").insert({
        "user_id": g.current_user["id"],
        "mood_name": mood
    }).execute()

    return jsonify({'message': 'Mood logged successfully!'}), 201


@app.route('/api/mood/history', methods=['GET'])
def get_mood_history():
    if not g.current_user:
        return jsonify({'message': 'Authentication required.'}), 401

    res = supabase.table("mood_logs").select("mood_name, created_at").eq("user_id", g.current_user["id"]).order("created_at", desc=True).execute()
    return jsonify(res.data or []), 200


# --- Chat Endpoint ---
@app.route('/api/chat', methods=['POST'])
def chat():
    if not g.current_user:
        return jsonify({'message': 'Authentication required.'}), 401
    if not supabase or not groq:
        return jsonify({"error": "Backend server not configured correctly."}), 500

    data = request.get_json()
    message = data.get("message")
    mood = data.get("mood")
    if not message or not mood:
        return jsonify({"error": "Message and mood are required"}), 400

    # Fetch profile + moods
    profile_res = supabase.table("profiles").select("profile_data").eq("id", g.current_user["id"]).single().execute()
    profile_data = profile_res.data or {}
    profile_data = profile_data.get("profile_data", {})

    moods_res = supabase.table("mood_logs").select("mood_name").eq("user_id", g.current_user["id"]).order("created_at", desc=True).limit(5).execute()
    moods = moods_res.data or []

    coping_mechanism = profile_data.get("coping_mechanism", "Not specified")
    mood_summary = ", ".join([m['mood_name'] for m in moods]) or "No recent moods"

    system_prompt = f"You are SoulScribe, an empathetic AI companion. The user is currently feeling '{mood}'. Their preferred coping mechanism is '{coping_mechanism}'. Their recent moods are: {mood_summary}. Tailor your response to be supportive and relevant."

    try:
        chat_completion = groq.chat.completions.create(
            model="llama3-8b-8192",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": message},
            ],
        )
        reply = chat_completion.choices[0].message.content
        return jsonify({"reply": reply}), 200

    except Exception as e:
        print(f"Chat error: {e}")
        return jsonify({"error": str(e)}), 500


# --- Server Start ---
if __name__ == '__main__':
    app.run(debug=True, port=5000)
