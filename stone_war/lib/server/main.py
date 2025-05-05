import firebase_admin
from firebase_admin import firestore
from google.cloud import functions_v2

# Firebase 초기화
firebase_admin.initialize_app()

# Firestore 클라이언트 생성
db = firestore.client()

def check_win(board, x, y, player):
    """5개 연속 돌이 있는지 확인하는 함수"""
    size = 15
    directions = [
        (1, 0),  # 가로
        (0, 1),  # 세로
        (1, 1),  # 대각선 ↘
        (-1, 1), # 대각선 ↙
    ]

    for dx, dy in directions:
        count = 1
        # 오른쪽 / 아래 방향 검사
        for i in range(1, 5):
            nx, ny = x + dx * i, y + dy * i
            if nx < 0 or ny < 0 or nx >= size or ny >= size:
                break
            if board[nx * size + ny] != player:
                break
            count += 1

        # 왼쪽 / 위쪽 방향 검사
        for i in range(1, 5):
            nx, ny = x - dx * i, y - dy * i
            if nx < 0 or ny < 0 or nx >= size or ny >= size:
                break
            if board[nx * size + ny] != player:
                break
            count += 1

        if count >= 5:
            return True
    return False

@functions_v2.cloud_event
def check_winner(event):
    """Firestore의 게임 데이터 변경 감지하여 승리 판정"""
    # Firestore 이벤트에서 데이터 가져오기
    data = event.data
    game_id = event.subject.split('/')[-1]
    game_ref = db.collection("games").document(game_id)

    # 게임 데이터 가져오기
    game_data = data["value"]["fields"]
    board = [int(x["integerValue"]) for x in game_data["board"]["arrayValue"]["values"]]
    current_player = int(game_data["currentTurn"]["integerValue"])
    
    # 마지막으로 둔 돌 찾기
    for x in range(15):
        for y in range(15):
            if board[x * 15 + y] == current_player:
                if check_win(board, x, y, current_player):
                    game_ref.update({"winner": current_player})
                    print(f"Game {game_id}: Player {current_player} wins!")
                    return
