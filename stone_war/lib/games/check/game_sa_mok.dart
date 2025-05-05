int check(int x, int y, List<List<int>> pan, int length) {
  // 가로줄 확인
  if (y <= 3) {
    // 오른쪽으로 이동 가능한 범위
    for (int i = 0; i < length; i++) {
      if (pan[x][y + i] != pan[x][y]) {
        break;
      }
      if (i == length - 1) {
        return pan[x][y];
      }
    }
  }

  // 세로줄 확인
  if (x <= 2) {
    // 아래로 이동 가능한 범위
    for (int i = 0; i < length; i++) {
      if (pan[x + i][y] != pan[x][y]) {
        break;
      }
      if (i == length - 1) {
        return pan[x][y];
      }
    }
  }

  // 오른쪽 위 대각선 확인
  if (x >= 3 && y <= 3) {
    // 대각선 위로 이동 가능한 범위
    for (int i = 0; i < length; i++) {
      if (pan[x - i][y + i] != pan[x][y]) {
        break;
      }
      if (i == length - 1) {
        return pan[x][y];
      }
    }
  }

  // 오른쪽 아래 대각선 확인
  if (x <= 2 && y <= 3) {
    // 대각선 아래로 이동 가능한 범위
    for (int i = 0; i < length; i++) {
      if (pan[x + i][y + i] != pan[x][y]) {
        break;
      }
      if (i == length - 1) {
        return pan[x][y];
      }
    }
  }

  return 0; // 조건을 만족하지 않을 경우 0 반환
}

void gravity(int direction, List<List<int>> pan) {
  for (int k = 0; k < 5; k++) {
    // 중력 반복 적용
    switch (direction) {
      case 0: // 아래
        for (int i = pan.length - 2; i >= 0; i--) {
          // 마지막 행 바로 위까지만 탐색
          for (int j = 0; j < pan[i].length; j++) {
            if (pan[i][j] != 0 && pan[i + 1][j] == 0) {
              pan[i + 1][j] = pan[i][j]; // 돌을 아래로 이동
              pan[i][j] = 0; // 원래 자리는 비움
            }
          }
        }
        break;
    }
  }
}
