//
//  main.cpp
//  denseboards
//
//  Created by John McCutchan on 6/8/13.
//  Copyright (c) 2013 John McCutchan. All rights reserved.
//

#include <cstdio>
#include <cstring>
#include <iostream>
#include <fstream>
#include <unordered_set>
#include <unordered_map>
#include <string>
#include <cassert>
#include <random>
#include <functional>
#include <algorithm>
#include <set>
#include <pthread.h>
#include <unistd.h>

using std::set;
using std::unordered_set;
using std::unordered_map;
using std::string;

unordered_map<string, int> _score;
unordered_set<string> _dictionary;
std::default_random_engine generator;
std::uniform_int_distribution<int> letterDistribution(0, 25);
std::uniform_int_distribution<int> perturbDistribution(0, 3);
std::uniform_int_distribution<int> indexDistribution(0, 3);
std::uniform_int_distribution<int> directionDistribution(0, 7);

#define N 4
#define ITERATIONS 100
#define NUM_BOARDS 1000

#define WORKER_THREADS 8
pthread_t workers[WORKER_THREADS];
pthread_mutex_t working_mutex;
pthread_mutex_t work_mutex[WORKER_THREADS];
pthread_cond_t work_cond[WORKER_THREADS];
pthread_mutex_t counter_mutex;
volatile int counter = WORKER_THREADS;

void* thread_worker_start(void* arg);

void start_workers() {
  pthread_mutex_init(&counter_mutex, NULL);
  for (int i = 0; i < WORKER_THREADS; i++) {
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_ERRORCHECK);
    int r = pthread_mutex_init(&work_mutex[i], &attr);
    assert(r >= 0);
    r = pthread_cond_init(&work_cond[i], NULL);
    assert(r >= 0);
  }
  for (int i = 0; i < WORKER_THREADS; i++) {
    int r = pthread_create(&workers[i], NULL, thread_worker_start, &workers[i]);
    assert(r >= 0);
  }
}

void signal_workers() {
  // Signal the threads
  pthread_mutex_lock(&counter_mutex);
  assert(counter == 4);
  for (int i = 0; i < WORKER_THREADS; i++) {
    int r = pthread_cond_signal(&work_cond[i]);
    counter--;
    assert(r == 0);
  }
  pthread_mutex_unlock(&counter_mutex);
}

void lock_workers() {
  for (int i = 0; i < WORKER_THREADS; i++) {
    int r = pthread_mutex_lock(&work_mutex[i]);
    assert(r == 0);
  }
}

void unlock_workers() {
  for (int i = 0; i < WORKER_THREADS; i++) {
    int r = pthread_mutex_unlock(&work_mutex[i]);
    assert(r == 0);
  }
}

void stop_workers() {
  signal_workers();
  for (int i = 0; i < WORKER_THREADS; i++) {
    pthread_join(workers[i], NULL);
  }
}


void buildScore() {
  _score["A"] = 1;
  _score["B"] = 3;
  _score["C"] = 3;
  _score["D"] = 2;
  _score["E"] = 1;
  _score["F"] = 4;
  _score["G"] = 2;
  _score["H"] = 4;
  _score["I"] = 1;
  _score["J"] = 8;
  _score["K"] = 5;
  _score["L"] = 1;
  _score["M"] = 3;
  _score["N"] = 1;
  _score["O"] = 1;
  _score["P"] = 3;
  _score["Q"] = 10;
  _score["R"] = 1;
  _score["S"] = 1;
  _score["T"] = 1;
  _score["U"] = 1;
  _score["V"] = 4;
  _score["W"] = 4;
  _score["X"] = 8;
  _score["Y"] = 4;
  _score["Z"] = 10;
}

void buildDictionary(const char* path) {
  std::ifstream file(path);
  assert(file.is_open());
  while (file.good()) {
    std::string word;
    getline(file, word);
    _dictionary.insert(word);
  }
}

int calculateScore(const char* s) {
  int score = 0;

  int i = 0;
  int len = (int)strlen(s);

  while (i < len) {
    assert(s[i] != '\0');
    int letterScore = _score[string(1, s[i])];
    if (s[i] == 'Q') {
      i++;
      assert(s[i] == 'U');
    }
    i++;
    score += letterScore;
  }
  if (len <= 2) {
    return score;
  }
  if (len <= 4) {
    return score+1;
  }
  if (len == 5) {
    return score+2;
  }
  if (len == 6) {
    return score+3;
  }
  if (len == 7) {
    return score+5;
  }
  // 8 letter words get a score bonus of 11.
  return score+11;
}

char randomLetter() {
  return 'A' + letterDistribution(generator);
}

struct Board {
  char tiles[N][N];
  set<string> _usedWords;
  bool visited[N][N];
  int maxScore;
  
  Board() {
    maxScore = 0;
    generateRandom();
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        visited[i][j] = false;
      }
    }
  }

  void generateRandom() {
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        tiles[i][j] = randomLetter();
      }
    }
  }

  bool equal(const Board& other) {
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        if (tiles[i][j] != other.tiles[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  void print() {
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        printf("%c ", tiles[i][j]);
      }
      printf("\n");
    }
    printf("%d %ld\n", maxScore, _usedWords.size());
    auto it = _usedWords.begin();
    while (it != _usedWords.end()) {
      printf("%s ", (*it).c_str());
      it++;
    }
    printf("\n");
  }

  void printFinal() {
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        printf("%c ", tiles[i][j]);
      }
    }
    fprintf(stderr, "%d %ld\n", maxScore, _usedWords.size());
    auto it = _usedWords.begin();
    while (it != _usedWords.end()) {
      printf("%s ", (*it).c_str());
      it++;
    }
    printf("\n");
  }

  bool wordInBoardWorker(const char* word, int i, int j) {
    if (*word == '\0') {
      // Found word.
      return true;
    }
    // Outside board.
    if (i < 0 || j < 0 || i >= N || j >= N) {
      return false;
    }
    if (visited[i][j] == true) {
      return false;
    }
    char tileCh = tiles[i][j];
    if (tileCh != *word) {
      // Character not on board.
      return false;
    }
    int step = 1;
    if (tileCh == 'Q') {
      // A 'Q' tile consumes both a Q and a U character.
      if (*(word+step) != 'U') {
        return false;
      }
      step++;
    }

    visited[i][j] = true;

    bool r = false;

    r = r || wordInBoardWorker(word+step, i-1, j-1);
    r = r || wordInBoardWorker(word+step, i-1, j);
    r = r || wordInBoardWorker(word+step, i-1, j+1);

    r = r || wordInBoardWorker(word+step, i+1, j-1);
    r = r || wordInBoardWorker(word+step, i+1, j);
    r = r || wordInBoardWorker(word+step, i+1, j+1);

    r = r || wordInBoardWorker(word+step, i, j-1);
    r = r || wordInBoardWorker(word+step, i, j+1);

    visited[i][j] = false;

    return r;
  }

  bool wordInBoard(const char* word) {
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        if (wordInBoardWorker(word, i, j)) {
          return true;
        }
      }
    }
    return false;
  }

  bool calculateMaxScore() {
    int oldMaxScore = maxScore;
    _usedWords.clear();
    maxScore = 0;
    auto it = _dictionary.begin();
    while (it != _dictionary.end()) {
      const char* word = (*it).c_str();
      if (wordInBoard(word)) {
        maxScore += calculateScore(word);
        _usedWords.insert(*it);
      }
      it++;
    }
    return maxScore > oldMaxScore; // Improvement.
  }

  void tweak0(int num) {
    while (num >= 0) {
      int i = indexDistribution(generator);
      int j = indexDistribution(generator);
      tiles[i][j] = randomLetter();
      num--;
    }
  }

  void tweak1(int num) {
    while (num >= 0) {
      int i0 = indexDistribution(generator);
      int j0 = indexDistribution(generator);
      int i1 = i0;
      int j1 = j0;
      switch (directionDistribution(generator)) {
        case 0:
          i1++;
          break;
        case 1:
          i1--;
          break;
        case 2:
          j1++;
          break;
        case 3:
          j1--;
          break;
        case 4:
          i1++;
          j1++;
          break;
        case 5:
          i1--;
          j1--;
          break;
        case 6:
          i1--;
          j1++;
          break;
        case 7:
          i1++;
          j1--;
          break;
      }
      if (i1 >= 0 && i1 < N && j1 >= 0 && j1 < N) {
        std::swap(tiles[i0][j0], tiles[i1][j1]);
        num--;
      }
    }
  }

  void tweak2(int num) {
    while (num >= 0) {
      int i0 = indexDistribution(generator);
      int j0 = indexDistribution(generator);
      int i1 = indexDistribution(generator);
      int j1 = indexDistribution(generator);
      std::swap(tiles[i0][j0], tiles[i1][j1]);
      num--;
    }
  }

  void tweak3(int num) {
    Board temp(*this);
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        tiles[i][j] = temp.tiles[(i+num)%N][(i+num)%N];
      }
    }
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        tiles[i][j] = temp.tiles[(j+num)%N][(j+num)%N];
      }
    }
  }

  void tweak(int i, int num) {
    switch (i) {
      case 0:
        tweak0(num);
        break;
      case 1:
        tweak1(num);
        break;
      case 2:
        tweak2(num);
        break;
      case 3:
        tweak3(num);
        break;
      default:
        assert(i < 4 && i >= 0);
    }
  }
};

bool operator>(const Board& a, const Board& b) {
  return a.maxScore > b.maxScore;
}

std::vector<Board> boards(NUM_BOARDS*2);
volatile bool finished = false;

void* thread_worker_start(void* arg) {
  pthread_t* self = reinterpret_cast<pthread_t*>(arg);
  int id = (int)(self - &workers[0]);
  fprintf(stderr, "Thread %d started.\n", id);
  pthread_mutex_t* mutex = &work_mutex[id];
  pthread_cond_t* monitor = &work_cond[id];
  pthread_mutex_lock(mutex);

  while (!finished) {
    while (true) {
      fprintf(stderr, "%d waiting for signal.\n", id);
      int r = pthread_cond_wait(monitor, mutex);
      assert(r >= 0);
      break;
    }
    if (finished) {
      pthread_mutex_lock(&counter_mutex);
      counter++;
      pthread_mutex_unlock(&counter_mutex);
      fprintf(stderr, "%d signaled and finished.\n", id);
      break;
    }
    fprintf(stderr, "%d signaled and working.\n", id);
    int boards_per_thread = (NUM_BOARDS / WORKER_THREADS);
    int src_index = id * boards_per_thread;
    int dst_index = src_index + NUM_BOARDS;
    for (int i = 0; i < boards_per_thread; i++) {
      int tweakType = perturbDistribution(generator);
      boards[dst_index+i] = boards[src_index+i];
      boards[dst_index+i].tweak(tweakType, 8);
      boards[dst_index+i].calculateMaxScore();
    }
    pthread_mutex_lock(&counter_mutex);
    counter++;
    pthread_mutex_unlock(&counter_mutex);
  }
  int r = pthread_mutex_unlock(mutex);
  assert(r >= 0);
  return NULL;
}

void* thread_worker_start1(void* arg) {
  pthread_t* self = reinterpret_cast<pthread_t*>(arg);
  int id = (int)(self - &workers[0]);
  fprintf(stderr, "Thread %d started.\n", id);
  int boards_per_thread = (NUM_BOARDS / WORKER_THREADS);
  int src_index = id * boards_per_thread;
  int dst_index = src_index + NUM_BOARDS;
  for (int i = 0; i < boards_per_thread; i++) {
    int tweakType = perturbDistribution(generator);
    boards[dst_index+i] = boards[src_index+i];
    boards[dst_index+i].tweak(tweakType, 8);
    boards[dst_index+i].calculateMaxScore();
  }
  pthread_exit(NULL);
}

void uniqueBoards(std::vector<Board>& boards) {
  size_t len = boards.size()/2;
  int dupCount = 0;
  for (int i = 0; i < len; i++) {
    for (int j = i+1; j < len; j++) {
      if (boards[i].equal(boards[j])) {
        // Generate random new board.
        boards[i].generateRandom();
        // Start over and verify we haven't generated a random board
        // equal to one of our existing boards.
        j = i+1;
        dupCount++;
      }
    }
  }
  fprintf(stderr, "Found %d duplicates.\n", dupCount);
}

void tweakBoards(std::vector<Board>& boards) {
  int half = (int)boards.size()/2;
  for (int i = 0; i < half; i++) {
    int tweakType = perturbDistribution(generator);
    boards[half+i] = boards[i];
    boards[half+i].tweak(tweakType, 8);
    boards[half+i].calculateMaxScore();
  }
}

void buildTopBoards(int numBoards) {
  auto it = boards.begin();
  // Initial update.
  while (it != boards.end()) {
    it->calculateMaxScore();
    it++;
  }
  std::sort(boards.begin(), boards.end(), std::greater<Board>());

  for (int i = 0; i < ITERATIONS; i++) {
    fprintf(stderr, "%d/%d\n", i, ITERATIONS);
    fflush(stderr);
    tweakBoards(boards);
    std::sort(boards.begin(), boards.end(), std::greater<Board>());
  }
  boards.resize(numBoards);
}


void buildTopBoardsParallel(int numBoards) {
  auto it = boards.begin();
  // Initial update.
  while (it != boards.end()) {
    it->calculateMaxScore();
    it++;
  }
  std::sort(boards.begin(), boards.end(), std::greater<Board>());
  // All workers are sleeping at condition variable.
  for (int i = 0; i < ITERATIONS; i++) {
    signal_workers();
    while (true) {
      pthread_mutex_lock(&counter_mutex);
      if (counter == WORKER_THREADS) {
        pthread_mutex_unlock(&counter_mutex);
        break;
      }
      pthread_mutex_unlock(&counter_mutex);
      usleep(1);
    }
    fprintf(stderr, "%d/%d\n", i, ITERATIONS);
    fflush(stderr);
    // All workers are sleeping at condition variable.
    std::sort(boards.begin(), boards.end(), std::greater<Board>());
  }
  lock_workers();
  unlock_workers();
  signal_workers();
  finished = true;
  boards.resize(numBoards);
}


void buildTopBoardsParallel1(int numBoards) {
  auto it = boards.begin();
  // Initial update.
  while (it != boards.end()) {
    it->calculateMaxScore();
    it++;
  }
  std::sort(boards.begin(), boards.end(), std::greater<Board>());
  for (int i = 0; i < ITERATIONS; i++) {
    for (int i = 0; i < WORKER_THREADS; i++) {
      int r = pthread_create(&workers[i], NULL, thread_worker_start1,
                             &workers[i]);
      assert(r == 0);
    }
    for (int i = 0; i < WORKER_THREADS; i++) {
      int r = pthread_join(workers[i], NULL);
      assert(r == 0);
    }
    fprintf(stderr, "%d/%d\n", i, ITERATIONS);
    fflush(stderr);
    std::sort(boards.begin(), boards.end(), std::greater<Board>());
    uniqueBoards(boards);
  }
  boards.resize(numBoards);
}


int main(int argc, const char * argv[]) {
  static_assert((NUM_BOARDS % WORKER_THREADS) == 0, "Invalid config.");
//  start_workers();
  buildScore();
  buildDictionary("/Users/johnmccutchan/dictionary.txt");
  buildTopBoardsParallel1(NUM_BOARDS);
  auto it = boards.begin();
  while (it != boards.end()) {
    it->printFinal();
    it++;
  }
//  stop_workers();
  fprintf(stderr, "Exiting.\n");
}
