class Gene {
  boolean gene;

  Gene (EnumInitMode im) {
    this.init(im);
  }

  void init (EnumInitMode im) {
    switch (im) {
    case RANDOM:
      this.gene = (random(1.0) < 0.5);
      break;
    case TRUE:
    case ONES:
      this.gene = true;
      break;
    default:
      this.gene = false;
    }
  }

  // --------------------------------------------------
  boolean getGene () {
    return this.gene;
  }

  String getPrintGene () {
    return (this.gene ? "T" : "F");
  }

  void setGene (boolean g) {
    this.gene = g;
  }

  // --------------------------------------------------
  void mutate () {
    this.gene = !this.gene;
  }

  //// --------------------------------------------------
  //void crossover (Gene p, Gene m, EnumCrossoverMode cm) {
  //  //this.gene = !this.gene;
  //}

  //void crossover (Gene p, Gene m, EnumCrossoverMode cm, int idx, int cut) {
  //  //this.gene = !this.gene;
  //}

  //void crossover (Gene p, Gene m, EnumCrossoverMode cm, int idx, int cut, int recut) {
  //  //this.gene = !this.gene;
  //}

  // --------------------------------------------------
  float fit (boolean exp) {
    return (exp == this.gene) ? 1.0 : 0.0;
  }

  // --------------------------------------------------
  void gprint () {
    println(this.gene);
  }
}