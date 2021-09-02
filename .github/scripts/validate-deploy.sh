#!/usr/bin/env bash

ssh -i .private-key root@$(cat .public-ip) ls
