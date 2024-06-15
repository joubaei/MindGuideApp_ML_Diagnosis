from flask import Flask, request, jsonify
import joblib
import pandas as pd
import sklearn
print(sklearn.__version__)
from flask_cors import CORS

# Relative or environment-based path to the model file
model_file_path = "C:\\Users\\pc\\Desktop\\random_forest_model.pkl"
# Load the trained model
loaded_model = joblib.load(model_file_path)

# Initialize Flask app
app = Flask(__name__)
CORS(app)
@app.route('/predict', methods=['POST'])    
def predict():
    
    data = request.json

    if not data:
        return jsonify({'error': 'No data provided'}), 400

    # List of expected features
    expected_features = [
        'age', 'feeling.nervous', 'panic', 'breathing.rapidly', 'sweating', 
        'trouble.in.concentration', 'having.trouble.in.sleeping', 'having.trouble.with.work', 
        'hopelessness', 'anger', 'over.react', 'change.in.eating', 'suicidal.thought', 
        'feeling.tired', 'close.friend', 'social.media.addiction', 'weight.gain', 
        'introvert', 'popping.up.stressful.memory', 'having.nightmares', 
        'avoids.people.or.activities', 'feeling.negative', 
        'blamming.yourself', 'hallucinations', 'repetitive.behaviour', 'seasonally', 
        'increased.energy'
    ]

    # Verify all necessary data is present
    missing_features = [feature for feature in expected_features if feature not in data]
    if missing_features:
        return jsonify({'error': 'Missing data for features', 'missing_features': missing_features}), 400

    # Prepare data for prediction
    input_data = pd.DataFrame({feature: [data[feature]] for feature in expected_features})

    # Make predictions
    predictions = loaded_model.predict(input_data)

    return jsonify({'predictions': predictions.tolist()})

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=8001, use_reloader=False)