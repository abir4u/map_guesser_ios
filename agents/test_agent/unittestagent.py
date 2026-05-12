import os
import requests
import subprocess

# Your Local Ollama API
OLLAMA_URL = "http://localhost:11434/api/generate"


def ask_ai(prompt):
    data = {
        "model": "qwen2.5-coder:7b",
        "prompt": prompt,
        "stream": False
    }
    response = requests.post(OLLAMA_URL, json=data)
    return response.json()['response']


def run_tests():
    # Command to run iOS tests via terminal
    result = subprocess.run(
        [
            "xcodebuild", "test",
            "-scheme", "Map Guessr",
            "-destination", "platform=iOS Simulator,name=iPhone 17 Pro Max"
        ],
        capture_output=True, text=True
    )
    return result.stdout


# Agent Logic
def manage_tests():
    # 1. Read a specific Swift file from your project
    source_path = "../../Map Guessr/Services/LaunchService.swift"
    with open(source_path, "r") as f:
        code = f.read()

    # 2. Ask AI to write a unit test
    prompt = (
        f"Write a Swift XCTest for the following code. "
        f"Include '@testable import Map_Guessr' at the top. "
        f"Target code:\n\n{code}"
    )
    test_code = ask_ai(prompt)

    # 3. Save the test code to your project's Test folder
    test_dir = "../../Map GuessrTests/Services/LaunchServiceTests.swift"
    with open(test_dir, "w") as f:
        f.write(test_code)

    # 4. Execute and report
    print("Running tests...")
    output = run_tests()
    print(output)


if __name__ == "__main__":
    manage_tests()
