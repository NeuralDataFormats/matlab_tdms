# TDMS Reader

This is my second attempt at writing a TDMS reader for Matlab. The first one works just fine, but I learned a lot of lessons about the format and there are some things that are made more difficult than they need to be.

## Current Status

I have nearly finished the meta data processing of the file, at least for tdms files with accompanying .tdms_index files. Besides completing the meta data parsing for raw .tdms file, the next step is to implement the reader.

## Improvements

1. Speed. This implementation should be a lot faster.
2. Ease of use. By using handle classes, doing things like multiple reads in which the user holds onto the header information between reads should be easier. This also includes things like specialized reading of channels.
3. Better documentation.

