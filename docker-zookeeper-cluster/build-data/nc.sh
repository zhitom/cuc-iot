#!/bin/sh

echo $@ |nc `hostname` ${ZOO_PORT}

