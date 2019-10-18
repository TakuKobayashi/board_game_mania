#!/bin/sh

for file in `ls *.sql`; do
  git add "${file}"
  git commit "add dumped sql file"
done
