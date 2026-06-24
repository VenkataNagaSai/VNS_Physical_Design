group_path -from [get_flat_cells -filter "is_sequential" I_BLENDER_0/*] \
           -to   [get_flat_cells -filter "is_sequential" I_BLENDER_0/*] \
           -weight 2 \
           -name I_BLENDER_0_path
group_path -from [get_flat_cells -filter "is_sequential" I_BLENDER_1/*] \
           -to   [get_flat_cells -filter "is_sequential" I_BLENDER_1/*] \
           -weight 4 \
           -name I_BLENDER_1_path
