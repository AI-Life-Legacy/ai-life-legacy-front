import requests
import json
import time

BASE_URL = "http://localhost:3000"
TEST_EMAIL = f"test_{int(time.time())}@test.com"
TEST_PWD = "password123"

def test_apis():
    print(f"--- Starting API Tests with Email: {TEST_EMAIL} ---")
    
    # 1. Signup
    print("\n[1] Testing Signup...")
    try:
        signup_res = requests.post(
            f"{BASE_URL}/auth/signup",
            json={"email": TEST_EMAIL, "password": TEST_PWD}
        )
    except Exception as e:
        print(f"Connection Failed: {e}")
        return

    if signup_res.status_code not in [200, 201]:
        print(f"Signup Failed: {signup_res.status_code} - {signup_res.text}")
        return
    
    token_data = signup_res.json()
    if isinstance(token_data, dict) and "data" in token_data:
        token_data = token_data["data"]
    elif isinstance(token_data, dict) and "result" in token_data:
        token_data = token_data["result"]
        
    access_token = token_data.get("accessToken")
    if not access_token:
        print(f"Token not found in response: {token_data}")
        return
    
    print("Signup Successful. Token obtained.")
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    # Helper function to print results
    def print_res(name, res):
        print(f"[{name}] Status: {res.status_code}")
        try:
            print(f"Response: {json.dumps(res.json(), indent=2, ensure_ascii=False)}")
        except:
            print(f"Response (text): {res.text}")

    # 2. Case Classification
    print("\n[2] Testing AI Case Classification (/api/case)...")
    res = requests.post(f"{BASE_URL}/api/case", headers=headers, json={"data": "저는 70대입니다."})
    print_res("Case", res)

    # 3. Memory Sync
    print("\n[3] Testing Memory Sync (/api/sync)...")
    res = requests.post(f"{BASE_URL}/api/sync", headers=headers, json={"content": "테스트 기억"})
    print_res("Sync", res)

    # 4. Follow-up Question
    print("\n[4] Testing Follow-up Question (/api/question)...")
    res = requests.post(f"{BASE_URL}/api/question", headers=headers, json={"question": "질문", "data": "답변"})
    print_res("Question", res)

    # 5. Autobiography Generation
    print("\n[5] Testing Autobiography Generation (/api/autobiography)...")
    res = requests.post(f"{BASE_URL}/api/autobiography", headers=headers)
    print_res("Autobiography", res)

    # 6. Avatar Chat
    print("\n[6] Testing Avatar Chat (/api/chat)...")
    res = requests.post(f"{BASE_URL}/api/chat", headers=headers, json={"message": "안녕", "role": "아버지"})
    print_res("Chat", res)

    # 7. Record Search
    print("\n[7] Testing Record Search (/api/search)...")
    res = requests.post(f"{BASE_URL}/api/search", headers=headers, json={"query": "테스트"})
    print_res("Search", res)

if __name__ == "__main__":
    test_apis()
