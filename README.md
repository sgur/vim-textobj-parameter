vim-textobj-parameter
=====================

vim-textobj-parameter is a Vim plugin to provide text objects (`a,` and `i,` by
default) to select parameters of functions.

Usage
-----

-   `i,` to inner parameter object

    ```vim
    function(param_a, param_b, param_c)
             |<--->|  |<--->|  |<--->|
    ```

-   `a,` to a parameter object including whitespaces and comma

    ```vim
    function(param_a, param_b, param_c)
             |<----->|
    function(param_a, param_b, param_c)
                    |<----->|
    function(param_a, param_b, param_c)
                             |<----->|
    ```

-   In addition, 'i2,' is similar to `a,` except trailing whitespace characters (especially for first parameter)

    ```vim
    function(param_a, param_b, param_c)
             |<---->|
    ```

Configuration
-------------

By default this motion is mapped to ',' (comma).  The key mapping can be overridden by adding a line similar to this to your vimrc:

```vim
    let g:vim_textobj_parameter_mapping = ','
```

Requirement
-----------

- [vim-textobj-user](https://github.com/kana/vim-textobj-user)

License
-------

MIT License

Author
------

- Original: [ampmmn](http://d.hatena.ne.jp/ampmmn/20100224/1267020691)
- Modified: sgur <mailto:sgurrr@gmail.com>
