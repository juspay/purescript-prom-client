module Prometheus.Client where

import Prelude

import Control.Monad.Eff (Eff)
import Data.Foreign.Class (class Encode, encode)
import Data.Function.Uncurried (Fn2, Fn3, Fn6, runFn2, runFn3, runFn6)
import Node.Express.Types (ExpressM, Response, Request)

foreign import data Metric :: Type
foreign import data Timer :: Type
foreign import emptyTimer :: forall e. Eff e Timer
foreign import promClusterMetrics :: forall e. Fn3 Request Response (ExpressM e Unit) (ExpressM e Unit)
foreign import initCounterImpl :: forall e. Fn3 String String (Array String) (Eff e Metric)
foreign import initHistogramImpl :: forall e. Fn6 String String (Array String) Number Number Number (Eff e Metric)
foreign import incrementCounterImpl :: forall a e. Fn2 Metric a (Eff e Metric)
foreign import addLabelsImpl :: forall e labels. Fn2 Metric labels (Eff e Metric)
foreign import startTimerImpl :: forall e labels. Fn2 Metric labels (Eff e Timer)
foreign import endTimerImpl :: forall e labels. Fn3 Metric labels Timer (Eff e Unit)

initCounter :: forall e. String -> String -> Array String -> Eff e Metric
initCounter name desc labels = runFn3 initCounterImpl name desc labels

incrementCounter :: forall a e . Encode a => Metric -> a -> Eff e Metric
incrementCounter counter labelRec = runFn2 incrementCounterImpl counter (encode labelRec)

initHistogram :: forall e. String -> Array String -> Number -> Number -> Number -> Eff e Metric
initHistogram name labels bucketStart bucketEnd factor =
  runFn6 initHistogramImpl name name labels bucketStart bucketEnd factor

startTimer :: forall a e. Encode a => Metric -> a -> Eff e Timer
startTimer histogram labelRec  =
  runFn2 startTimerImpl histogram (encode labelRec)

endTimer :: forall a e. Encode a => Metric -> a -> Timer  -> Eff e Unit
endTimer histogram labels timer = runFn3 endTimerImpl histogram (encode labels) timer
