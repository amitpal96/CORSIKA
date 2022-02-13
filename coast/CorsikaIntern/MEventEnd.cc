/* $Id$   */

#include <crs/MEventEnd.h>
using namespace crs;

MEventEnd::MEventEnd (const TSubBlock &right) {

  // ctor
  fSubBlockData = right.fSubBlockData;
  fType = right.fType;
  fThinned = right.fThinned;
}

