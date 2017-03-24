class Population {
  Chromosome[] population;
  int size;
  EnumCrossoverMode crossoverMode;
  EnumMutationMode mutationMode;
  EnumInitMode initMode;
  EnumSortMode sortMode;
  int cutPoint;
  int recutPoint;
  float mutationRate;
  int chromosomeLength;
  float maxFitness;
  float midFitness;
  float minFitness;
  int currId;

  Chromosome target;

  Population (int nb, int cl) {
    this.size = nb;
    this.chromosomeLength = cl;
    this.population = new Chromosome[this.size];
    this.currId = 0;
    this.init();
  }

  void init() {
    this.setInitMode(EnumInitMode.RANDOM);
    this.setCrossoverMode(EnumCrossoverMode.CUTPOINT);
    this.setMutationMode(EnumMutationMode.UNIQUE);
    this.setSortMode(EnumSortMode.INSERT);
    this.setMutationRate(5.0); // %
    this.setCutPoint(5, 10);
  }

  // --------------------------------------------------
  void setCrossoverMode (EnumCrossoverMode cm) {
    this.crossoverMode = cm;
  }

  void setInitMode (EnumInitMode im) {
    this.initMode = im;
  }

  void setMutationMode (EnumMutationMode mm) {
    this.mutationMode = mm;
  }

  void setMutationRate (float mr) {
    this.mutationRate = mr;
  }

  void setSortMode (EnumSortMode sm) {
    this.sortMode = sm;
  }

  void setCutPoint (int cut) {
    this.cutPoint = cut;
    this.recutPoint = this.size;
  }

  void setCutPoint (int cut1, int cut2) {
    this.cutPoint = cut1;
    this.recutPoint = cut2;
  }

  // --------------------------------------------------
  void setTarget (boolean[] valtarget) {
    this.target = new Chromosome(this.chromosomeLength);
    for (int i = 0; i < this.chromosomeLength; i++) {
      this.target.genes[i].setGene(valtarget[i]);
    }
  }

  float getMaxFitness () {
    return this.maxFitness;
  }

  float getMinFitness () {
    return this.minFitness;
  }

  float getMidFitness () {
    return this.midFitness;
  }

  void setId (int idx, int pid0, int pid1) {
    this.population[idx].setId(this.currId, pid0, pid1);
    this.currId++;
  }

  // --------------------------------------------------
  void generate () {
    for (int i = 0; i < this.size; i++) {
      this.population[i] = new Chromosome(this.chromosomeLength, this.initMode, this.crossoverMode, this.mutationMode, this.mutationRate, this.cutPoint, this.recutPoint);
      this.setId(i, -1, -1);
    }
  }

  // --------------------------------------------------
  void fitness () {
    this.minFitness = 1e10;
    this.maxFitness = -1.0;
    float f;
    float sum = 0.0;
    for (int i = 0; i < this.size; i++) {
      this.population[i].fitness(this.target);
      f = this.population[i].getFitness();
      sum += f;
      this.minFitness = min(this.minFitness, f);
      this.maxFitness = max(this.maxFitness, f);
    }
    this.midFitness = sum / this.size;
  }

  // --------------------------------------------------
  void swap (int idx1, int idx2) {
    Chromosome tmp = new Chromosome(this.chromosomeLength);
    tmp = population[idx1];
    this.population[idx1] = this.population[idx2];
    this.population[idx2] = tmp;
  }

  void bubblesort () {
    float kj, kjp1;
    for (int i = 0; i < this.size-1; i++) {
      for (int j = 0; j < this.size-1-i; j++) {
        kj = this.population[j].getFitness();
        kjp1 = this.population[j+1].getFitness();
        if ((kj < kjp1)) {
          swap(j, j+1);
        }
      }
    }
  }

  void insertionsort () {
    float k;
    int j;
    for (int i = 1; i < this.size; i++) {
      k = this.population[i].getFitness();
      j = i-1;
      while ((j >= 0) && (k > this.population[j].getFitness())) {
        swap(j, j+1);
        j--;
      }
    }
  }

  void selectionsort () {
    float max, kj, ki;
    int maxIdx;
    for (int i = 0; i < this.size; i++) {
      ki = this.population[i].getFitness();
      max = ki;
      maxIdx = i;
      for (int j = i; j < this.size; j++) {
        kj = this.population[j].getFitness();
        if (kj > max) {
          max = kj;
          maxIdx = j;
        }
      }
      if (max > ki) {
        swap(i, maxIdx);
      }
    }
  }

  // --------------------------------------------------
  void select () {
    switch (this.sortMode) {
    case BUBBLE:
      this.bubblesort();
      break;
    case SELECT:
      this.selectionsort();
      break;
    default:
      this.insertionsort();
    }
    if (DEBUG) {
      println(" xxx Natural selection");
    }
    for (int i = floor(this.size/2.0); i < this.size; i++) {
      this.population[i].lifeState = EnumLifeState.DEAD;
    }
  }

  // --------------------------------------------------
  void mate () {
    Chromosome[] children = new Chromosome[2];
    children[0] = new Chromosome(this.chromosomeLength);
    children[1] = new Chromosome(this.chromosomeLength);

    int h = floor(this.size / 2.0);
    int id0, id1;
    int offset;
    for (int i = 0; i < h; i += 2) {
      id0 = i;
      id1 = (i+1) % h;
      offset = h + i;
      children = this.population[id0].crossover(this.population[id1]); // if (this.size/2) is odd, then [0] (best) gets another chance to mate!
      this.population[id0].lifeState   = EnumLifeState.ALIVE;
      this.population[id1].lifeState = EnumLifeState.ALIVE; // if (this.size/2) is odd, then [0] (best) set twice to ALIVE, but it's not an issue.
      if (DEBUG) {
        println(" xxx Cross : P" + id0 + " x P" + (id1));
      }
      for (int ch = 0; ch < 2; ch ++) {
        if ((offset+ch) < this.size) {
          if (DEBUG) {
            println(" xxx New Child : n°" + (offset+ch));
          }
          this.population[offset+ch] = children[ch];
          this.setId(offset+ch, this.population[id0].id, this.population[id1].id);
          this.population[offset+ch].lifeState = EnumLifeState.BORN;
          this.population[offset+ch].mutate();
        }
      }
    }
  }

  // --------------------------------------------------
  void pprint() {
    for (int i = 0; i < this.size; i++) {
      print("Individus n°" + i + " ");
      this.population[i].gprint();
    }
  }

  // --------------------------------------------------
  void fprint() {
    println("* Min fitness = " + this.minFitness);
    println("* Mid fitness = " + this.midFitness);
    println("* Max fitness = " + this.maxFitness);
    for (int i = 0; i < this.size; i++) {
      print("_Individus n°" + i + " (" + this.population[i].getLifeState() + ")");
      this.population[i].gprint();
      this.population[i].fprint();
      this.population[i].iprint();
      this.population[i].pprint();
      this.population[i].mprint();
      println();
    }
  }
}