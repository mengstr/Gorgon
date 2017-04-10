#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cat $1 | $DIR/wrap.sh | $DIR/offset.sh 0 | $DIR/convert.sh 0 
cat $1 | $DIR/wrap.sh | $DIR/offset.sh 2 | $DIR/convert.sh 1 
cat $1 | $DIR/wrap.sh | $DIR/offset.sh 4 | $DIR/convert.sh 2 
cat $1 | $DIR/wrap.sh | $DIR/offset.sh 6 | $DIR/convert.sh 3 
