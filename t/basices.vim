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
          \ 'function s:function(param_a, param_b, param_c)'
          \ , '  echo ...'
          \ , 'endfunction'
          \ , ]
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
    Expect [line("'<"), col("'<")] ==# [1, 29]
    Expect [line("'>"), col("'>")] ==# [1, 38]
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
    Expect [line("'["), col("'[")] ==# [1, 29]
    Expect [line("'["), col("']")] ==# [1, 38]
    normal! 0f,;l
    execute "silent normal y\<Plug>(textobj-parameter-a)"
    Expect [line("'["), col("'[")] ==# [1, 37]
    Expect [line("']"), col("']")] ==# [1, 45]
  end
end




" describe '<Plug>(textobj-parameter-i)'
"   before
"     tabnew
"     tabonly!
"
"     silent put =[
"           \   'if some_condition_is_satisfied',
"           \   '  if another_condition_is_satisfied',
"           \   '    call s:special_stuff()',
"           \   '  endif',
"           \   '  call s:normal_stuff()',
"           \   '',
"           \   '  ...',
"           \   '  endif',
"           \   'else',
"           \   '  ...',
"           \   'endif',
"           \ ]
"     1 delete _
"     normal! 4G
"   end
"
"   it 'selects proper range of text'
"     execute "normal v\<Plug>(textobj-indent-i)\<Esc>"
"     Expect [line("'<"), col("'<")] ==# [2, 1]
"     Expect [line("'>"), col("'>")] ==# [5, 24]
"   end
"
"   it 'targets proper range of text'
"     execute "silent normal y\<Plug>(textobj-indent-i)"
"     Expect [line("'["), col("'[")] ==# [2, 1]
"     Expect [line("']"), col("']")] ==# [5, 24]
"   end
" end
"
"
"
"
" describe '<Plug>(textobj-parameter-greedy-i)'
"   before
"     tabnew
"     tabonly!
"
"     silent put =[
"           \   'if some_condition_is_satisfied',
"           \   '  if another_condition_is_satisfied',
"           \   '    call s:special_stuff()',
"           \   '  endif',
"           \   '  call s:normal_stuff()',
"           \   '',
"           \   '  ...',
"           \   '  endif',
"           \   'else',
"           \   '  ...',
"           \   'endif',
"           \ ]
"     1 delete _
"     normal! 4G
"   end
"
"   it 'selects proper range of text'
"     execute "normal v\<Plug>(textobj-indent-same-i)\<Esc>"
"     Expect [line("'<"), col("'<")] ==# [4, 1]
"     Expect [line("'>"), col("'>")] ==# [5, 24]
"   end
"
"   it 'targets proper range of text'
"     execute "silent normal y\<Plug>(textobj-indent-same-i)"
"     Expect [line("'["), col("'[")] ==# [4, 1]
"     Expect [line("']"), col("']")] ==# [5, 24]
"   end
" end
