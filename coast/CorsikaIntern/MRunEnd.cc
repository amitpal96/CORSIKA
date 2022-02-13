/* $Id$   */

#include <crs/MRunEnd.h>
using namespace crs;

MRunEnd::MRunEnd (const TSubBlock &right) {

  // ctor
  fSubBlockData = right.fSubBlockData;
  fType = right.fType;
  fThinned = right.fThinned;
}
