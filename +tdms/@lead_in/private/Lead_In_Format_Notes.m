%{

                        Lead In Format Notes
===========================================================================

Summary size - 28 bytes (7 words)

The lead in consists of 5 parts:
1) lead in flag
    - 4 bytes
    - either TDSh or TDSm 
2) toc mask
    - 4 bytes
    - 
3) version number
    - uint32
4) segment length
    - uint64

5) meta length
    - uint64



LENGTH SUMMARIES
------------------------------------------
Lead In - 28 bytes (7 words)
Segment Length - length of meta data specification and raw data (does not
include the length of the lead in)
Meta Length - length of the meta information, to get to the raw data add
this value to current byte address after reading the lead in
Data Length - Segment Length - Meta Length

%}