" vim-textobj-parameter - Text objects for function parameter.
" Version: 0.2.1
" Author: ampmmn(htmnymgw <delete>@<delete> gmail.com)
" Modifier: sgur(sgurrr <delete>@<delete> gmail.com)
" URL: http://d.hatena.ne.jp/ampmmn
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}

" Interface  "{{{1


" i,
function! textobj#parameter#select_i()  "{{{2
	return s:select(s:const_skip_space)
endfunction


" i2,
function! textobj#parameter#select_greedy_i()  "{{{2
	return s:select_surrounds(0)
endfunction


" a,
function! textobj#parameter#select_a()  "{{{2
	return s:select_surrounds(1)
endfunction


" Misc.  "{{{1
" variables {{{2
" 検索の際、結果から除外するシンタックス名のパターン
" Patterns that exclude after search
if !exists('g:textobj_parameter_ignore_syntax')
	let g:textobj_parameter_ignore_syntax = ['comment','string','character']
endif

" 区切り文字
let s:separators = [',',';']
" ネストを考慮する括弧のペア
let s:bracket_pairs = [['(',')'], ['[',']'],['{','}'],['<','>']]


function! s:select_surrounds(include_surrounds) "{{{
	let result = s:select(!s:const_skip_space)
	if type(result) == type(0)
		return 0
	endif

	let [spos, epos] = [result[1], result[2]]

	" 左側に隣接するのがcomma/semicolonだったら、それも含めて削除
	call cursor(spos[1:2])
	let [start_chr, spos_new] = s:search_pos('b', [',',';','(','<','[','{'],[])
	if a:include_surrounds
		let spos_new = s:skip_ws_backward(spos_new)
	endif
	if start_chr == ',' || start_chr == ';'
		let result[1] = s:normalize(spos_new)
		return result
	endif

	" 右側に隣接するのがcomma/semicolonだったら、それも含めて削除
	call cursor(epos[1:2])
	let [end_chr, epos_new] = s:search_pos('', [',',';',')','>',']','}'],[])
	if a:include_surrounds
		let epos_new = s:skip_ws_forward(epos_new)
	endif
	if end_chr == ',' || end_chr == ';'
		let result[2] = s:normalize(epos_new)
		return result
	endif

	" どちらでもなければ、select_iと同じ挙動
	return result
endfunction "}}}

" 連続する空白をスキップする
function! s:skip_ws_forward(pos) "{{{
	let [lnum, col] = a:pos
	let line = getline(lnum)
	for c in range(col, len(line)-1)
		if line[c] != ' '
			return [lnum, c]
		endif
	endfor
	return a:pos
endfunction "}}}

function! s:skip_ws_backward(pos) "{{{
	let [lnum, col] = a:pos
	let line = getline(lnum)
	for c in range(col-1, 1, -1)
		if line[c-1] != ' '
			return [lnum, c+1]
		endif
	endfor
	return a:pos
endfunction "}}}

" 指定した位置のシンタックスが文字列またはコメントかどうかを判定
function! s:is_ignore_syntax(pos)  "{{{
	let syn_name = synIDattr(synID(a:pos[0], a:pos[1],1), "name")
	for item in g:textobj_parameter_ignore_syntax
		if type(item) == type('') && syn_name =~? item
			return 1
		endif
	endfor
	return 0
endfunction "}}}

" 検索パターン文字列の作成
function! s:create_search_pattern(separators, bracket_pairs) "{{{
	" 区切り文字をマッチさせる部分のパターンを作成
	let sep_pattern =''
	for item in a:separators
		let sep_pattern .= (len(sep_pattern) > 0? '\|': '') . '\%(' . item . '\)'
	endfor
	" 括弧をマッチさせる部分のパターンを作成
	let bracket_pattern = ''
	for x in range(0, len(a:bracket_pairs)-1)
		let chr = a:bracket_pairs[x][1]
		let chr_rev = a:bracket_pairs[x][0]
		if x != 0| let bracket_pattern .= '\|' | endif
		let bracket_pattern .= '\%(' . chr . '\)\|\%(' . chr_rev . '\)'
	endfor
	" 作成したパターンを連結
	let search_pattern = sep_pattern
	if sep_pattern != '' && bracket_pattern != ''
		let search_pattern .= '\|'
	endif
	return '\V' . search_pattern . bracket_pattern
endfunction "}}}

" 括弧の階層レベルデータを作成
function! s:create_bracket_level_info(bracket_pairs) "{{{
	let chr_dict_index = {}
	let counts = []
	" 括弧をマッチさせる部分のパターンを作成
	let bracket_pattern = ''
	for x in range(0, len(a:bracket_pairs)-1)
		let chr = a:bracket_pairs[x][1]
		let chr_rev = a:bracket_pairs[x][0]
		let chr_dict_index[chr] = [x, -1]
		let chr_dict_index[chr_rev] = [x, 1]
		let counts += [ a:bracket_pairs[x][2] ]
	endfor
	return [ chr_dict_index, counts ]
endfunction "}}}

" コメント、文字列等を除外してのserachpos
function! s:searchpos(pat, opt)	"{{{
	" 検索のためのループ
	while 1
		let mpos = searchpos(a:pat, a:opt)
		if mpos == [0,0] || s:is_ignore_syntax(mpos) == 0
			return mpos
		endif
	endwhile
endfunction "}}}

" カーソル位置にある文字が、比較演算子としての<,>なのか、
" またはポインタ演算子としての->なのかを判定
function! s:is_inequality_or_pointer_operator(chr, bracket_pairs) "{{{
	if a:chr != '<' && a:chr != '>'
		return 0
	endif

	" 現在位置を保持しておく(この関数を抜ける際に位置を復元するため)
	let [ cur_l,cur_c ] = getpos(".")[1:2]

	" ポインタ演算子(->) かどうかを判定
	let line_string = getline(cur_l)
	if a:chr == '>' && cur_c >= 2 && line_string[cur_c-2] == '-'
		return 1
	endif

	" <,>に対応する逆括弧が存在するなら、
	" それはテンプレートパラメータであるものとみなす
	let is_reverse = a:chr == '>'
	let bracket_pairs = []
	for item in a:bracket_pairs
		let bracket_pairs += [ [ item[is_reverse? 1: 0], item[is_reverse? 0: 1], 1] ]
	endfor
	" 検索パターン文字列の作成
	let search_pattern = s:create_search_pattern([], bracket_pairs)
	let [ chr_dict_index, counts ] = s:create_bracket_level_info(bracket_pairs)

	let result = 1
	" 検索のためのループ
	while(1)
		let mpos = s:searchpos(search_pattern, a:chr=='>'? 'bW': 'W')
		if mpos == [0,0]
			break
		endif
		" ヒットした位置の文字を取得
		let chr = getline('.')[mpos[1]-1]

		" 検索した位置のキャラクタに応じて階層深さリストのカウントを変更
		let x = chr_dict_index[chr][0]
		let counts[x] += chr_dict_index[chr][1]

		if counts[x]!=0
			continue
		endif

		let result = (chr != '>' && chr != '<')
		break
	endwhile
	" カーソルを元の位置に戻す
	call cursor(cur_l, cur_c)
	return result
endfunction "}}}

" 現在位置のキャラクタが区切り文字かどうかを判定
function! s:is_separator_chars(chr, separators) "{{{
	" 見つかった文字が区切り文字リスト内にあった場合、
	" ループを継続するかどうかを判定する
	return index(a:separators, a:chr) != -1
endfunction "}}}

" Check surrounded by quote or escaped char
function! s:is_surrounded_or_escaped() abort "{{{
	return getline('.') =~ "'.*\\%" . col('.') . "c.*'"
				\ || getline('.') =~ '".*\%' . col('.') . 'c.*"'
				\ || getline('.')[col('.')-2] == '\'
endfunction "}}}

" 区切り文字のある位置を検索する
" bracket_pairsで指定した括弧のネストを考慮して検索する。
function! s:search_pos(search_opt, separators, bracket_pairs) "{{{

	" bracket_pairsをa:search_optに応じて複製を作成
	let bracket_pairs = []
	for item in a:bracket_pairs
		let ritem = deepcopy(item)
		" 前方検索の時には、閉じ括弧で階層レベル+1,
		" 開き括弧で階層レベル-1とするために、括弧の反転を行う
		if stridx(a:search_opt, 'b') != -1
			let [ ritem[0], ritem[1] ] = [ ritem[1], ritem[0] ]
		endif
		" bracket_pairsリスト内の要素が階層レベル情報を持たない場合、階層レベル値を追加
		if len(ritem) == 2
			let ritem += [1] " 現在の階層レベルを表す値(初期状態1->0になったらブロック終了を意味する)
		endif
		let bracket_pairs += [ ritem ]
	endfor

	" 現在位置を保持しておく(この関数を抜ける際に位置を復元するため)
	let cur_pos = getpos(".")[1:2]

	" 検索パターン文字列の作成
	let search_pattern = s:create_search_pattern(a:separators, bracket_pairs)
	let [ chr_dict_index, counts ] = s:create_bracket_level_info(bracket_pairs)

	" 検索のためのループ
	while 1
		let mpos = s:searchpos(search_pattern, a:search_opt . 'W')
		if mpos == [0,0]
			break
		endif
		" ヒットした位置の文字を取得
		let chr = getline('.')[mpos[1]-1]
		" 見つかった文字が区切り文字リスト内にあった場合、
		" ループを継続するかどうかを判定する
		if s:is_separator_chars(chr, a:separators + [['''', ''''],['"', '"']]) != 0
			if len(counts) == 0 || count(counts,1) == len(counts)
				call cursor(cur_pos)
				return [ chr, mpos ]
			endif
			continue
		endif
		" 見つかった文字が<>の場合、それがテンプレートパラメータとしての記号なのかを判定
		if s:is_inequality_or_pointer_operator(chr, a:bracket_pairs) != 0
			continue
		endif

		" 検索した位置のキャラクタに応じて階層深さリストのカウントを変更
		let x = chr_dict_index[chr][0]
		let counts[x] += chr_dict_index[chr][1]

		if counts[x]!=0
			continue
		endif

		" カーソルを元の位置に戻す
		call cursor(cur_pos)

		" もし、階層深さカウントが 2以上の要素は、ただしく括弧が閉じられていないので
		" 検索対象から除外した上で再試行する
		let retry = 0
		for x in range(0, len(counts)-1)
			if counts[x] <= 1
				continue
			endif
			call remove(bracket_pairs, x)
			let retry = 1
		endfor
		if retry != 0
			" 検索パターン文字列を作り直す
			let search_pattern = s:create_search_pattern(a:separators, bracket_pairs)
			let [ chr_dict_index, counts ] = s:create_bracket_level_info(bracket_pairs)
			continue
		endif
		return [ chr, mpos ]
	endwhile
	call cursor(cur_pos)
	return [ '', cur_pos ]
endfunction "}}}

" 行、列番号の補正
function! s:normalize(pos) "{{{
	let [lineNr,colNr] = a:pos
	if colNr > len(getline(lineNr))
		let lineNr = lineNr+1
		let colNr = 1
	elseif colNr <= 0
		let lineNr = lineNr-1
		let colNr = len(getline(lineNr))
	endif
	return [0, lineNr, colNr, 0]
endfunction "}}}

" 検索結果のチェック
" 必要があれば、ここでtextobj#user側に渡す値の補正をおこなう
function! s:filter(start_chr, spos, end_chr, epos, skip_space) "{{{

	" C/C++の構文からいくと、{ .. ; という選択がなされた場合は無効でいいはず
	" (「ブロック先頭～ステートメントの終わり」という範囲選択は、このプラグインの意図するものではないため)
	if (a:start_chr == '{' && a:end_chr == ';') || (a:start_chr == ';' && a:end_chr == '}')
		return 0
	endif

	" ; ... ; というペアの場合、その外側の括弧は()であるかどうかを確認する
	" ; ... ; はC/C++ではfor文の中以外で、許可する必要はない・・はず
	if a:start_chr == ';' && a:end_chr == ';'
		call cursor(a:spos)
		let [ chr, pos ] = s:search_pos('b', [], s:bracket_pairs)
		if chr != '('
			return 0
		endif
	endif

	let [spos, epos] = [a:spos, a:epos]
	if a:skip_space != 0
		" 空白をスキップ
		call cursor(spos)
		let spos = searchpos('\S', 'W')
		call cursor(epos)
		let epos = searchpos('\S', 'bW')
	else
		" 区切り文字を選択範囲から外すために、それぞれ1文字ずつ狭める
		let spos[1] += 1
		let epos[1] -= 1
	endif

	return ['v', s:normalize(spos), s:normalize(epos)]
endfunction "}}}

" 指定したカーソル位置のテキストを取得
function! s:get_current_cursor_text(pos) "{{{

	let chr = getline(a:pos[0])[a:pos[1]-1]
	if index(s:separators, chr) != -1
		return chr
	endif

	let text = expand('<cword>')
	if index(s:separators, text) != -1
		return text
	endif

	return chr
endfunction "}}}

function! s:select(skip_space) "{{{
	let chr = s:get_current_cursor_text(getpos('.')[1:2])
	" Note: 一文字が前提になってしまっているのはなんとかしたいところ

	" 現在のカーソル位置が区切り文字の場合は何もしない
	if s:is_separator_chars(chr, s:separators) != 0 && !s:is_surrounded_or_escaped()
		return 0
	endif

	" 現在のカーソル位置の文字が({<[]>})だったら、初期階層レベルを変更
	let [ bracket_pairs_b, bracket_pairs_f ] = [ [], [] ]
	for item in s:bracket_pairs
		let bracket_pairs_b += [ item + [chr == item[1]? 2: 1] ]
		let bracket_pairs_f += [ item + [chr == item[0]? 2: 1] ]
	endfor

	" 始点行,列番号を決定
	let [start_chr, spos] = s:search_pos('b', s:separators, bracket_pairs_b)
	" 終点行,列番号を決定
	let [end_chr, epos] = s:search_pos('', s:separators, bracket_pairs_f)
	" 前方、後方のいずれかで文字をみつけられなかった場合は何も選択しない
	if start_chr == '' || end_chr == ''
		return 0
	endif

	" 検索結果のチェック
	return s:filter(start_chr, spos, end_chr, epos, a:skip_space)
endfunction "}}}

let s:const_skip_space = 1

" vim: ts=2 sw=2 noet
