from flask import Flask, request, jsonify
import redis
import os

app = Flask(__name__)

redis_host = os.getenv("REDIS_HOST", "localhost")
r = redis.Redis(host=redis_host, port=6379, db=0)

@app.route("/memo", methods=["POST"])
def add_memo():
    data = request.json
    r.rpush("memos", data["text"])
    return jsonify({"status": "ok"}), 201

@app.route("/memo", methods=["GET"])
def get_memos():
    memos = r.lrange("memos", 0, -1)
    memos = [m.decode() for m in memos]
    return jsonify(memos)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
