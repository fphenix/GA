// Fred Limouzin - 2017
//

boolean DEBUG = false;

Population pop;
boolean[] target = {true, false, true, false, true, false, true, false, true, false, false, false, true, false, true, false, true, false, true, false, true};

int chromosomeLen = 21;
int nbIndividuals = 50;
int maxIterations = 1000;

void setup() {
  pop = new Population(nbIndividuals, chromosomeLen);
  pop.setInitMode(EnumInitMode.RANDOM);
  pop.setCrossoverMode(EnumCrossoverMode.CUTPOINT);
  pop.setMutationMode(EnumMutationMode.UNIQUE);
  pop.setSortMode(EnumSortMode.INSERT);
  pop.setMutationRate(5.0); // %
  pop.setCutPoint(5, 10);

  pop.setTarget(target);

  println("Initial Generation");
  pop.generate();
  pop.fitness();
  pop.fprint();

  int iter = maxIterations;
  do {
    println();
    println("Iteration #" + (maxIterations - iter));
    pop.select();
    pop.mate();
    pop.fitness();
    pop.fprint();
    iter--;
  } while ((iter >= 0) && ((pop.getMaxFitness() < chromosomeLen) || (pop.getMidFitness() < (chromosomeLen * 0.98))));

  println();
  println("Final Generation");
  pop.select();
  pop.fprint();
}

void draw() {
  noLoop();
}