(module
   (import "env" "caml_ml_get_channel_fd"
      (func $caml_ml_get_channel_fd (param (ref eq)) (result i32)))
   (import "env" "caml_ml_set_channel_fd"
      (func $caml_ml_set_channel_fd (param (ref eq)) (param i32)))
   (import "env" "caml_ml_get_channel_offset"
      (func $caml_ml_get_channel_offset (param (ref eq)) (result i64)))
   (import "env" "caml_js_global"
      (func $caml_js_global (param (ref eq)) (result (ref eq))))
   (import "env" "caml_js_get"
      (func $caml_js_get (param (ref eq)) (param (ref eq)) (result (ref eq))))
   (import "env" "wrap" (func $wrap (param anyref) (result (ref eq))))
   (import "env" "unwrap" (func $unwrap (param (ref eq)) (result anyref)))

   (global $saved_stdout (mut i32) (i32.const 0))
   (global $saved_stderr (mut i32) (i32.const 0))

   (func (export "alcotest_before_test")
      (param $output (ref eq)) (param $stdout (ref eq)) (param $stderr (ref eq))
      (result (ref eq))
      (local $fd i32)
      (global.set $saved_stdout
         (call $caml_ml_get_channel_fd (local.get $stdout)))
      (global.set $saved_stderr
         (call $caml_ml_get_channel_fd (local.get $stderr)))
      (local.set $fd (call $caml_ml_get_channel_fd (local.get $output)))
      (call $caml_ml_set_channel_fd (local.get $stdout) (local.get $fd))
      (call $caml_ml_set_channel_fd (local.get $stderr) (local.get $fd))
      (ref.i31 (i32.const 0)))

   (func (export "alcotest_after_test")
      (param $stdout (ref eq)) (param $stderr (ref eq)) (result (ref eq))
      (call $caml_ml_set_channel_fd (local.get $stdout)
         (global.get $saved_stdout))
      (call $caml_ml_set_channel_fd (local.get $stderr)
         (global.get $saved_stderr))
      (ref.i31 (i32.const 0)))

   (type $block (array (mut (ref eq))))
   (type $string (array (mut i8)))

   (func $is_null (param (ref eq)) (result i32)
      (ref.is_null (call $unwrap (local.get 0))))

   (data $process "process")
   (data $stdout "stdout")
   (data $columns "columns")
   (data $rows "rows")

   (func (export "ocaml_alcotest_get_terminal_dimensions")
      (param (ref eq)) (result (ref eq))
      (local $p (ref eq)) (local $stdout (ref eq))
      (local $columns (ref eq)) (local $rows (ref eq))
      (local.set $p
         (call $caml_js_get (call $caml_js_global (ref.i31 (i32.const 0)))
            (array.new_data $string $process (i32.const 0) (i32.const 7))))
      (block $unknown
         (br_if $unknown (call $is_null (local.get $p)))
         (local.set $stdout
            (call $caml_js_get (local.get $p)
               (array.new_data $string $stdout (i32.const 0) (i32.const 6))))
         (br_if $unknown (call $is_null (local.get $stdout)))
         (local.set $columns
            (call $caml_js_get (local.get $stdout)
               (array.new_data $string $columns (i32.const 0) (i32.const 7))))
         (local.set $rows
            (call $caml_js_get (local.get $stdout)
               (array.new_data $string $rows (i32.const 0) (i32.const 4))))
         (br_if $unknown (i32.eqz (ref.test (ref i31) (local.get $columns))))
         (br_if $unknown (i32.eqz (ref.test (ref i31) (local.get $rows))))
         (return
            (array.new_fixed $block 2 (ref.i31 (i32.const 0))
               (array.new_fixed $block 3 (ref.i31 (i32.const 0))
                  (local.get $rows) (local.get $columns)))))
      (ref.i31 (i32.const 0)))
)
