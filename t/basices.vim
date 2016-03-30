runtime! plugin/textobj/*.vim


describe 'The plugin'
  it 'is loaded'
    Expect exists('g:loaded_textobj_parameter') to_be_true
  end
end


describe 'Named key mappings'
  it 'is available in proper modes'
    for lhs in [
          \   '<Plug>(textobj-parameter-a)'
          \ , '<Plug>(textobj-parameter-i)'
          \ , '<Plug>(textobj-parameter-greedy-i)'
          \ ]
      Expect maparg(lhs, 'c') == ''
      Expect maparg(lhs, 'i') == ''
      Expect maparg(lhs, 'n') == ''
      Expect maparg(lhs, 'o') != ''
      Expect maparg(lhs, 'v') != ''
    endfor
  end
end


describe 'Default key mappings'
  it 'is available in proper modes'
    Expect maparg('a,', 'c') ==# ''
    Expect maparg('a,', 'i') ==# ''
    Expect maparg('a,', 'n') ==# ''
    Expect maparg('a,', 'o') ==# '<Plug>(textobj-parameter-a)'
    Expect maparg('a,', 'v') ==# '<Plug>(textobj-parameter-a)'
    Expect maparg('i,', 'c') ==# ''
    Expect maparg('i,', 'i') ==# ''
    Expect maparg('i,', 'n') ==# ''
    Expect maparg('i,', 'o') ==# '<Plug>(textobj-parameter-i)'
    Expect maparg('i,', 'v') ==# '<Plug>(textobj-parameter-i)'
    Expect maparg('i2,', 'c') ==# ''
    Expect maparg('i2,', 'i') ==# ''
    Expect maparg('i2,', 'n') ==# ''
    Expect maparg('i2,', 'o') ==# '<Plug>(textobj-parameter-greedy-i)'
    Expect maparg('i2,', 'v') ==# '<Plug>(textobj-parameter-greedy-i)'
  end
end


describe '<Plug>(textobj-parameter-a)'
  before
    tabnew
    tabonly!

    silent put =[
          \   'function s:function(param_a, param_b, param_c)'
          \ , '+---------+---------+---------+---------+---------+'
          \ , '1       10        20        30        40        50'
          \ , '  echo ...'
          \ , 'endfunction'
          \ ]
    1 delete _
    normal! 1G
  end

  it 'selects proper range of text'
    normal! 0f(l
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 21]
    Expect [line("'>"), col("'>")] ==# [1, 29]
    normal! 0f,l
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 28]
    Expect [line("'>"), col("'>")] ==# [1, 36]
    normal! 0f,;l
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 37]
    Expect [line("'>"), col("'>")] ==# [1, 45]
  end

  it 'targets proper range of text'
    normal! 0f(l
    execute "silent normal y\<Plug>(textobj-parameter-a)"
    Expect [line("'["), col("'[")] ==# [1, 21]
    Expect [line("']"), col("']")] ==# [1, 29]
    normal! 0f,l
    execute "silent normal y\<Plug>(textobj-parameter-a)"
    Expect [line("'["), col("'[")] ==# [1, 28]
    Expect [line("'["), col("']")] ==# [1, 36]
    normal! 0f,;l
    execute "silent normal y\<Plug>(textobj-parameter-a)"
    Expect [line("'["), col("'[")] ==# [1, 37]
    Expect [line("']"), col("']")] ==# [1, 45]
  end
end


describe '<Plug>(textobj-parameter-a)-2'
  before
    tabnew
    tabonly!

    silent put =[
          \   'function s:function( param_a   ,   param_b   , param_c )'
          \ , '+---------+---------+---------+---------+---------+---------+'
          \ , '1       10        20        30        40        50        60'
          \ , '  echo ...'
          \ , 'endfunction'
          \ ]
    1 delete _
    normal! 1G
  end

  it 'selects proper range of text'
    normal! 0f(l
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 21]
    Expect [line("'>"), col("'>")] ==# [1, 35]
    normal! 0f,l
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 29]
    Expect [line("'>"), col("'>")] ==# [1, 45]
    normal! 0f,;l
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 43]
    Expect [line("'>"), col("'>")] ==# [1, 55]
  end
end


describe '<Plug>(textobj-parameter-a) issue#3'
  before
    tabnew
    tabonly!

    source $VIMRUNTIME/syntax/php.vim
    silent put =[
          \   '<?php'
          \ , 'implode('','', $foo);'
          \ ]
    1 delete _
    normal! 2G
  end

  it 'selects proper range of text when cursor is in first comma surrounded by quote'
    normal! 0f'
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [2, 9]
    Expect [line("'>"), col("'>")] ==# [2, 13]
  end

  it 'targets proper range of text when cursor is in second comma surrounded by quote'
    normal! 0f,
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [2, 9]
    Expect [line("'>"), col("'>")] ==# [2, 13]
  end

  it 'targets proper range of text when cursor is in third comma surrounded by quote'
    normal! 02f'
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [2, 9]
    Expect [line("'>"), col("'>")] ==# [2, 13]
  end

end


describe '<Plug>(textobj-parameter-a) issue#3-more'
  before
    tabnew
    tabonly!

    source $VIMRUNTIME/syntax/vim.vim
    " call s:function(',,,', 123, 456)
    " call s:function(",,,", 123, 456)
    " call s:function('\,,\,', 123, 456)
    " +---------+---------+---------+---------+---------+'
    " 1       10        20        30        40        50'
    silent put =[
          \   'call s:function('',,,'', 123, 456)'
          \ , 'call s:function(\",,,\", 123, 456)'
          \ , 'call s:function(''\,,\,'', 123, 456)'
          \ ]
    1 delete _
    normal! 1G
  end

  it 'selects proper range of text when cursor is in first comma surrounded by quote'
    normal! 1G0f,
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 17]
    Expect [line("'>"), col("'>")] ==# [1, 23]
  end

  it 'targets proper range of text when cursor is in second comma surrounded by quote'
    normal! 1G02f,
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 17]
    Expect [line("'>"), col("'>")] ==# [1, 23]
  end

  it 'targets proper range of text when cursor is in third comma surrounded by quote'
    normal! 1G03f,
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 17]
    Expect [line("'>"), col("'>")] ==# [1, 23]
  end

  it 'selects proper range of text when cursor is in first comma surrounded by double quote'
    normal! 2G0f,
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [2, 17]
    Expect [line("'>"), col("'>")] ==# [2, 23]
  end

  it 'targets proper range of text when cursor is in second comma surrounded by double quote'
    normal! 2G02f,
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [2, 17]
    Expect [line("'>"), col("'>")] ==# [2, 23]
  end

  it 'targets proper range of text when cursor is in third comma surrounded by double quote'
    normal! 2G03f,
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [2, 17]
    Expect [line("'>"), col("'>")] ==# [2, 23]
  end

  it 'selects proper range of text when cursor is in first escaped comma'
    normal! 3G0f,
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [3, 17]
    Expect [line("'>"), col("'>")] ==# [3, 25]
  end

  it 'targets proper range of text when cursor is in second comma surrounded by escaped comma'
    normal! 3G02f,
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [3, 17]
    Expect [line("'>"), col("'>")] ==# [3, 25]
  end

  it 'targets proper range of text when cursor is in third escaped comma'
    normal! 3G03f,
    execute "normal v\<Plug>(textobj-parameter-a)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [3, 17]
    Expect [line("'>"), col("'>")] ==# [3, 25]
  end
end


describe '<Plug>(textobj-parameter-i)'
  before
    tabnew
    tabonly!

    " function s:function(param_a, param_b, param_c)
    "|---------+---------+---------+---------+---------|
    "0         10        20     |  30    |  |40   |    50
    "                     |-----|  |     |  |     |
    "                              |-----|  |     |
    "                                       |-----|
    silent put =[
          \ 'function s:function(param_a, param_b, param_c)'
          \ , '  echo ...'
          \ , 'endfunction'
          \ , ]
    1 delete _
    normal! 1G
  end

  it 'selects proper range of text'
    normal! 0f(l
    execute "normal v\<Plug>(textobj-parameter-i)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 21]
    Expect [line("'>"), col("'>")] ==# [1, 27]
    normal! 0f,l
    execute "normal v\<Plug>(textobj-parameter-i)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 30]
    Expect [line("'>"), col("'>")] ==# [1, 36]
    normal! 0f,;l
    execute "normal v\<Plug>(textobj-parameter-i)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 39]
    Expect [line("'>"), col("'>")] ==# [1, 45]
  end

  it 'targets proper range of text'
    normal! 0f(l
    execute "silent normal y\<Plug>(textobj-parameter-i)"
    Expect [line("'["), col("'[")] ==# [1, 21]
    Expect [line("']"), col("']")] ==# [1, 27]
    normal! 0f,l
    execute "silent normal y\<Plug>(textobj-parameter-i)"
    Expect [line("'["), col("'[")] ==# [1, 30]
    Expect [line("'["), col("']")] ==# [1, 36]
    normal! 0f,;l
    execute "silent normal y\<Plug>(textobj-parameter-i)"
    Expect [line("'["), col("'[")] ==# [1, 39]
    Expect [line("']"), col("']")] ==# [1, 45]
  end
end




describe '<Plug>(textobj-parameter-greedy-i)'
  before
    tabnew
    tabonly!

    " function s:function(param_a, param_b, param_c)
    "|---------+---------+---------+---------+---------|
    "0         10        20      | 30    ||  40   |    50
    "                     |------|       ||       |
    "                            |-------||       |
    "                                     |-------|
    silent put =[
          \ 'function s:function(param_a, param_b, param_c)'
          \ , '  echo ...'
          \ , 'endfunction'
          \ , ]
    1 delete _
    normal! 1G
  end

  it 'selects proper range of text'
    normal! 0f(l
    execute "normal v\<Plug>(textobj-parameter-greedy-i)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 21]
    Expect [line("'>"), col("'>")] ==# [1, 28]
    normal! 0f,l
    execute "normal v\<Plug>(textobj-parameter-greedy-i)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 28]
    Expect [line("'>"), col("'>")] ==# [1, 36]
    normal! 0f,;l
    execute "normal v\<Plug>(textobj-parameter-greedy-i)\<Esc>"
    Expect [line("'<"), col("'<")] ==# [1, 37]
    Expect [line("'>"), col("'>")] ==# [1, 45]
  end

  it 'targets proper range of text'
    normal! 0f(l
    execute "silent normal y\<Plug>(textobj-parameter-greedy-i)"
    Expect [line("'["), col("'[")] ==# [1, 21]
    Expect [line("']"), col("']")] ==# [1, 28]
    normal! 0f,l
    execute "silent normal y\<Plug>(textobj-parameter-greedy-i)"
    Expect [line("'["), col("'[")] ==# [1, 28]
    Expect [line("'["), col("']")] ==# [1, 36]
    normal! 0f,;l
    execute "silent normal y\<Plug>(textobj-parameter-greedy-i)"
    Expect [line("'["), col("'[")] ==# [1, 37]
    Expect [line("']"), col("']")] ==# [1, 45]
  end
end
