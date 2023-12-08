  if [[  -n $1 ]]; then TICKET=$1; else read -p "Enter the deconstruction ticket: " TICKET; fi
  if [[  -n $2 ]]; then TARGETS=${@:2}; else read -p "Enter the deconstruction targets: " -a TARGETS; fi
