int check(int x, int y, List<List<int>> pan, int length) {
  // 가로줄 4칸 확인
  if (y < length) {
    for (int i = 0; i < length; i++) {
      if (pan[x][y + i] != pan[x][y]) {
        break;
      }
      if (i == length - 1) {
        return pan[x][y];
      }
    }
  }

  // 세로줄 4칸 확인
  if (x < length) {
    for (int i = 0; i < length; i++) {
      if (pan[x + i][y] != pan[x][y]) {
        break;
      }
      if (i == length - 1) {
        return pan[x][y];
      }
    }
  }

  // 오른쪽 위 대각선 4칸 확인
  if (x > length - 2 && y < length) {
    for (int i = 0; i < length; i++) {
      if (pan[x - i][y + i] != pan[x][y]) {
        break;
      }
      if (i == length) {
        return pan[x][y];
      }
    }
  }

  // 오른쪽 아래 대각선 4칸 확인
  if (x < length && y < length) {
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
  for (int k = 0; k < 7; k++) {
    switch (direction) {
      case 0: // 아래
        for (int i = 5; i >= 0; i--) {
          for (int j = 6; j >= 0; j--) {
            if (pan[i][j] != 0 && pan[i + 1][j] == 0) {
              pan[i + 1][j] = pan[i][j];
              pan[i][j] = 0;
            }
          }
        }
        break;

      case 1: // 오른쪽
        for (int j = 5; j >= 0; j--) {
          for (int i = 6; i >= 0; i--) {
            if (pan[i][j] != 0 && pan[i][j + 1] == 0) {
              pan[i][j + 1] = pan[i][j];
              pan[i][j] = 0;
            }
          }
        }
        break;

      case 2: // 위
        for (int i = 1; i < 7; i++) {
          for (int j = 0; j < 7; j++) {
            if (pan[i][j] != 0 && pan[i - 1][j] == 0) {
              pan[i - 1][j] = pan[i][j];
              pan[i][j] = 0;
            }
          }
        }
        break;

      case 3: // 왼쪽
        for (int i = 0; i < 7; i++) {
          for (int j = 1; j < 7; j++) {
            if (pan[i][j] != 0 && pan[i][j - 1] == 0) {
              pan[i][j - 1] = pan[i][j];
              pan[i][j] = 0;
            }
          }
        }
        break;
    }
  }
}
