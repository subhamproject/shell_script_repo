#!/bin/bash
TMOUT=5
echo You have 5 seconds to respond...
read
echo ${REPLY:-noreply}
