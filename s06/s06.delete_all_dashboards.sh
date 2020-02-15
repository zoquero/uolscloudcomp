#!/bin/bash

#
# Borra todos los dashboards (paneles)
#
# angel.galindo@uols.org
# 20200102
#

s=""
for i in $(aws2 cloudwatch list-dashboards | jq -r '.DashboardEntries[].DashboardName'); do
  s="$s $i"
done
aws2 cloudwatch delete-dashboards --dashboard-names $s 
