class Chromosome {
  Gene[] genes;
  int size;
  EnumCrossoverMode crossoverMode;
  EnumMutationMode mutationMode;
  EnumInitMode initMode;
  int cutPoint;
  int recutPoint;
  float mutationRate;
  int nbchildren = 2;
  float fitnessScore;
  EnumLifeState lifeState;
  int id;
  int[] pid;
  boolean mutated;

  Chromosome (int s) {
    this.beforeInit(s);
    this.init();
    this.afterInit();
  }

  void beforeInit(int s) {
    this.size = s;
    this.lifeState = EnumLifeState.ALIVE;
  }

  void init () {
    this.initMode = EnumInitMode.ZEROES;
    this.crossoverMode = EnumCrossoverMode.CUTPOINT;
    this.mutationMode = EnumMutationMode.UNIQUE;
    this.mutationRate = 5.0;
    this.cutPoint = floor(this.size / 2.0);
    this.recutPoint = this.size;
  }

  void defInit(int s, EnumInitMode im, EnumCrossoverMode cm, EnumMutationMode mm, float mr) {
    this.beforeInit(s);
    this.initMode = im;
    this.crossoverMode = cm;
    this.mutationMode = mm;
    this.mutationRate = mr;
  }

  void afterInit() {
    this.genes = new Gene[this.size];
    for (int i = 0; i < this.size; i++) {
      this.genes[i] = new Gene(this.initMode);
    }
    this.fitnessScore = 0.0;
    this.mutated = false;
    this.id = -1;
    this.pid = new int[2];
    this.pid[0] = -1;
    this.pid[1] = -1;
  }

  Chromosome (int s, EnumInitMode im, EnumCrossoverMode cm, EnumMutationMode mm, float mr) {
    this.defInit(s, im, cm, mm, mr);
    this.cutPoint = floor(this.size / 2.0);
    this.recutPoint = this.size;
    this.afterInit();
  }

  Chromosome (int s, EnumInitMode im, EnumCrossoverMode cm, EnumMutationMode mm, float mr, int cut) {
    this.defInit(s, im, cm, mm, mr);
    this.cutPoint = cut;
    this.recutPoint = this.size;
    this.afterInit();
  }

  Chromosome (int s, EnumInitMode im, EnumCrossoverMode cm, EnumMutationMode mm, float mr, int cut, int recut) {
    this.defInit(s, im, cm, mm, mr);
    this.cutPoint = cut;
    this.recutPoint = recut;
    this.afterInit();
  }

  // --------------------------------------------------
  int getSize () {
    return this.size;
  }

  int getId () {
    return this.id;
  }

  void setParentsId (int id0, int id1) {
    this.pid[0] = id0;
    this.pid[1] = id1;
  }

  void setId (int tid) {
    this.id = tid;
  }

  void setId (int tid, int id0, int id1) {
    this.setId(tid);
    this.setParentsId(id0, id1);
  }

  boolean getHasMutated () {
    return this.mutated;
  }

  String getLifeState () {
    switch (this.lifeState) {
    case ALIVE:
      return "Alive";
    case DEAD:
      return "Dead ";
    case BORN:
      return "Born ";
    default:
      return "Uknwn";
    }
  }

  float getFitness () {
    return this.fitnessScore;
  }

  // --------------------------------------------------
  void mutateOne () {
    float rnd = random(100.0);
    if (rnd < this.mutationRate) {
      int gnb = floor(random(this.size));
      this.genes[gnb].mutate();
      this.mutated = true;
      if (DEBUG) {
        println(" ... Mutation O: gene n°" + gnb);
      }
    }
  }

  // --------------------------------------------------
  void mutateAll () {
    float rnd;
    for (int i = 0; i < this.size; i++) {
      rnd = random(100.0);
      if (rnd < this.mutationRate) {
        this.genes[i].mutate();
        this.mutated = true;
        if (DEBUG) {
          println(" ... Mutation A: gene n°" + i);
        }
      }
    }
  }

  // --------------------------------------------------
  void mutate () {
    switch (this.mutationMode) {
    case GLOBAL:
      this.mutateAll();
      break;
    default:
      this.mutateOne();
    }
  }

  // --------------------------------------------------
  void fitness (Chromosome exp) {
    float f = 0.0;
    float tmp;
    for (int i = 0; i < this.size; i++) {
      tmp = (this.genes[i].fit(exp.genes[i].getGene())); //  / this.size;
      f += (tmp * tmp);
    }
    this.fitnessScore = f;
  }

  // --------------------------------------------------
  Chromosome[] crossover (Chromosome other) {
    Chromosome[] ch = new Chromosome[this.nbchildren]; // right now fixed to 2
    ch[0] = new Chromosome(this.size, this.initMode, this.crossoverMode, this.mutationMode, this.mutationRate, this.cutPoint, this.recutPoint);
    ch[1] = new Chromosome(this.size, this.initMode, this.crossoverMode, this.mutationMode, this.mutationRate, this.cutPoint, this.recutPoint);
    float rnd;
    int rndcut = floor(random(1, this.size-1));
    int rndrecut = floor(random(rndcut+1, this.size-1));
    for (int i = 0; i < this.size; i++) {
      switch (this.crossoverMode) {
      case DOUBLECUT:
        ch[0].genes[i].setGene((i < this.cutPoint) ? this.genes[i].getGene()  : ((i < this.recutPoint) ? other.genes[i].getGene() : this.genes[i].getGene()));
        ch[1].genes[i].setGene((i < this.cutPoint) ? other.genes[i].getGene() : ((i < this.recutPoint) ? this.genes[i].getGene()  : other.genes[i].getGene()));
        break;
      case DOUBLERANDOMCUT:
        ch[0].genes[i].setGene((i < rndcut) ? this.genes[i].getGene()  : ((i < rndrecut) ? other.genes[i].getGene() : this.genes[i].getGene() ));
        ch[1].genes[i].setGene((i < rndcut) ? other.genes[i].getGene() : ((i < rndrecut) ? this.genes[i].getGene()  : other.genes[i].getGene()));
        break;
      case RANDOM:
        rnd = random(1.0);
        ch[0].genes[i].setGene((rnd < 0.5) ? this.genes[i].getGene()  : other.genes[i].getGene());
        ch[1].genes[i].setGene((rnd < 0.5) ? other.genes[i].getGene() : this.genes[i].getGene());       
        break;
      case RANDOMCUT:
        ch[0].genes[i].setGene((i < rndcut) ? this.genes[i].getGene()  : other.genes[i].getGene());
        ch[1].genes[i].setGene((i < rndcut) ? other.genes[i].getGene() : this.genes[i].getGene());
        break;
      default: //cutpoint
        ch[0].genes[i].setGene((i < this.cutPoint) ? this.genes[i].getGene()  : other.genes[i].getGene());
        ch[1].genes[i].setGene((i < this.cutPoint) ? other.genes[i].getGene() : this.genes[i].getGene());
      }
    }    
    return ch;
  }

  // --------------------------------------------------
  void mprint () {
    print(" Mutant? : ", ((this.mutated) ? "Yes" : "No") + " ");
  }

  // --------------------------------------------------
  void iprint () {
    print(" ID : ", this.id + " ");
  }

  // --------------------------------------------------
  void pprint () {
    print(" Parent's IDs : ", this.pid[0] + " x " + this.pid[1]);
  }

  // --------------------------------------------------
  void fprint () {
    print(" Fitness : ", this.fitnessScore + " ");
  }

  // --------------------------------------------------
  void gprint () {
    print(" ");
    for (int i = 0; i < this.size; i++) {
      print(this.genes[i].getPrintGene());
    }
  }
}