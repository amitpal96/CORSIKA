/* $Id$   */

#include <crs/MEventHeader.h>
using namespace crs;

MEventHeader::MEventHeader (const TSubBlock &right) {

  // ctor
  fSubBlockData = right.fSubBlockData;
  fType = right.fType;
  fThinned = right.fThinned;
}
