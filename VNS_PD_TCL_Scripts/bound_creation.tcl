create_bound -name "movebound1" \
  -boundary {{{100 100} {200 200}} {{1000 1000} {2000 1000}} \
             {{2000 4000} {1500 4000}} {{1500 2000} {1000 2000}}} \
  -type hard -cells [get_cells I_CONTEXT_MEM/*]
