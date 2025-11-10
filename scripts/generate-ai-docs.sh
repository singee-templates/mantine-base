#!/bin/bash

set -euxo pipefail

mkdir -p .ai

wget https://mantine.dev/llms.txt -O .ai/mantine.md
wget https://context7.com/websites/tanstack_com-start-latest/llms.txt?tokens=1000000 -O .ai/tanstack-start.md
wget https://context7.com/websites/tanstack_router/llms.txt?tokens=1000000 -O .ai/tanstack-router.md