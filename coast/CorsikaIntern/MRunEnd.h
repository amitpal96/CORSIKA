#ifndef _INCLUDE_CORSIKA_MRUNEND_
#define _INCLUDE_CORSIKA_MRUNEND_

#include <crs/TSubBlock.h>
#include <crs/CorsikaTypes.h>

namespace crs {

  /** 
      \class MRunEnd
      \brief CORSIKA run end (RUNE) sub-block

      This class knows how to access the data stored in this sub-block type.

      \author Ralf Ulrich
      \date Thu Feb  3 13:04:50 CET 2005
      \version $Id$
  */

  class MRunEnd : public TSubBlock {
	
  public:
    MRunEnd () {}
    MRunEnd (const TSubBlock &right);
    virtual ~MRunEnd () {}
	
  public:
    CREAL GetRunNumber () const {return fSubBlockData [1];}
    CREAL GetEventsProcessed () const {return fSubBlockData [2];}
	
  };
};

#endif
