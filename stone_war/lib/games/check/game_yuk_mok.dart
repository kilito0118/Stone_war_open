int checkWinner(List<List<int>> board, int row, int col) {
  final player = board[row][col];
  if (player == 0) return 0;

  // 검사 방향: → ↓ ↘ ↙
  const directions = [
    [0, 1], // 가로
    [1, 0], // 세로
    [1, 1], // 대각선1
    [1, -1], // 대각선2
  ];

  for (final dir in directions) {
    int count = 1;
    int dx = dir[0];
    int dy = dir[1];

    // 정방향 검사 (최대 5칸)
    for (int i = 1; i <= 5; i++) {
      final newRow = row + dx * i;
      final newCol = col + dy * i;
      if (newRow < 0 || newRow >= 19 || newCol < 0 || newCol >= 19) break;
      if (board[newRow][newCol] != player) break;
      count++;
    }

    // 역방향 검사 (최대 5칸)
    for (int i = 1; i <= 5; i++) {
      final newRow = row - dx * i;
      final newCol = col - dy * i;
      if (newRow < 0 || newRow >= 15 || newCol < 0 || newCol >= 15) break;
      if (board[newRow][newCol] != player) break;
      count++;
    }

    if (count >= 6) return player;
  }
  return 0;
}
