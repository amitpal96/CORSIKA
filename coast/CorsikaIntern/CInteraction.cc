/* $Id$   */

#include <crs/CInteraction.h>
#include <crs/CorsikaConsts.h>

#include <iostream>
#include <cstdlib>

using namespace crs;
using namespace std;


void CInteraction::Dump () const {
  cout << "Interaction projectileId: " << projId << ", targetId: " << targetId
       << ", energy: " << etot
       << ", x: " << x 
       << ", y: " << y 
       << ", z: " << z
       << ", t: " << time
       << ", kela:" << kela
       << endl;
}


