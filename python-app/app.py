import os
from flask import Flask, jsonify, request
import boto3
from botocore.exceptions import ClientError

app = Flask(__name__)

s3 = boto3.client("s3")

BUCKET_NAME = os.getenv("BUCKET_NAME")


@app.route("/list-bucket-content/", defaults={"path": ""})
@app.route("/list-bucket-content/<path:path>", methods=["GET"])
def list_bucket_content(path):
    try:
        if not BUCKET_NAME:
            return (
                jsonify(
                    {"error": "S3 bucket name is not set in environment variables."}
                ),
                500,
            )

        prefix = path.strip("/")
        if not prefix:
            response = s3.list_objects_v2(Bucket=BUCKET_NAME, Delimiter="/")
        else:
            response = s3.list_objects_v2(
                Bucket=BUCKET_NAME, Prefix=prefix + "/", Delimiter="/"
            )

        if "CommonPrefixes" in response or "Contents" in response:
            content = []
            if "CommonPrefixes" in response:
                for cp in response["CommonPrefixes"]:
                    if cp["Prefix"] == prefix + "/":
                        content.append(cp["Prefix"].strip("/"))

            if "Contents" in response:
                for obj in response["Contents"]:
                    if obj["Key"] != prefix + "/":
                        content.append(obj["Key"].replace(prefix + "/", "", 1))

            return jsonify({"content": content})

        return jsonify({"content": []})

    except ClientError as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
