module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Effect.Ref as Ref
import Effect.Unsafe (unsafePerformEffect)
import Test.Assert (assert)
import Data.Lazy (defer, force)

main :: Effect Unit
main = do
  log "Testing Data.Lazy..."

  let l1 = defer \_ -> 42
  assert $ force l1 == 42

  let l2 = defer \_ -> "hello"
  assert $ force l2 == "hello"

  -- Test functor
  let l3 = map (_ + 1) l1
  assert $ force l3 == 43

  -- Test apply
  let l4 = apply (defer \_ -> \x -> x * 2) l1
  assert $ force l4 == 84

  -- Test bind
  let l5 = bind l1 (\x -> defer \_ -> x + 10)
  assert $ force l5 == 52

  log "Testing memoization (evaluation exactly once)..."
  counter <- Ref.new 0
  let l6 = defer \_ -> unsafePerformEffect do
        Ref.modify_ (_ + 1) counter
        pure 100

  count1 <- Ref.read counter
  log $ "count1: " <> show count1
  assert $ count1 == 0

  let val1 = force l6
  log ("val1: " <> show val1)
  if val1 == 100 then log "VAL1 IS 100" else log "VAL1 IS NOT 100"
  
  count2 <- Ref.read counter
  log $ "count2: " <> show count2
  assert $ count2 == 1

  -- Forcing again should not increment the counter
  let val2 = force l6
  assert $ val2 == 100

  count3 <- Ref.read counter
  log $ "count3: " <> show count3
  assert $ count3 == 1

  log "All tests passed!"
