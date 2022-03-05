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
3) version number
    - uint32
4) segment length
    - uint64

5) meta length
    - uint64


%When as uint8
%1:4  - lead in flag
%5:8  - toc mask
%9:12 - version number
%13:20 - segment length
%21:28 - meta length
%
%When as uint32
%1 - lead in flag
%2 - toc mask
%3 - version number
%4:5 - segment length
%6:7 - meta length

LENGTH SUMMARIES
---------------------------------------------------------------------------
Lead In - 28 bytes (7 words)

Segment Length - length of meta data specification and raw data (does not
include the length of the lead in)

Meta Length - length of the meta information, to get to the raw data add
this value to current byte address after reading the lead in

Data Length - Segment Length - Meta Length

%}