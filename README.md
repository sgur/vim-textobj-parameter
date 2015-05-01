vim-textobj-parameter
=====================

vim-textobj-parameter introduces text objects for parameters of functions.


Usage
-----

- `i,` to inner parameter object

    ```
    function(param_a, param_b, param_c)
             <----->  <----->  <----->
    ```

- `a,` to a parameter object including whitespaces and comma


    ```
    function(param_a, param_b, param_c)
             |<----->|
    function(param_a, param_b, param_c)
    	            |<----->|
    function(param_a, param_b, param_c)
                             |<----->|
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
- Modified: sgur <sgurrr@gmail.com>

