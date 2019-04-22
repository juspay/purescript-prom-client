{-
 Copyright (c) 2012-2017 "JUSPAY Technologies"
 JUSPAY Technologies Pvt. Ltd. [https://www.juspay.in]
 This file is part of JUSPAY Platform.
 JUSPAY Platform is free software: you can redistribute it and/or modify
 it for only educational purposes under the terms of the GNU Affero General
 Public License (GNU AGPL) as published by the Free Software Foundation,
 either version 3 of the License, or (at your option) any later version.
 For Enterprise/Commerical licenses, contact <info@juspay.in>.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  The end user will
 be liable for all damages without limitation, which is caused by the
 ABUSE of the LICENSED SOFTWARE and shall INDEMNIFY JUSPAY for such
 damages, claims, cost, including reasonable attorney fee claimed on Juspay.
 The end user has NO right to claim any indemnification based on its use
 of Licensed Software. See the GNU Affero General Public License for more details.
 You should have received a copy of the GNU Affero General Public License
 along with this program. If not, see <https://www.gnu.org/licenses/agpl.html>.
-}
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
foreign import incrementCounterByImpl :: forall a e. Fn3 Metric a Int (Eff e Metric)
foreign import addLabelsImpl :: forall e labels. Fn2 Metric labels (Eff e Metric)
foreign import startTimerImpl :: forall e labels. Fn2 Metric labels (Eff e Timer)
foreign import endTimerImpl :: forall e labels. Fn3 Metric labels Timer (Eff e Unit)
foreign import observeImpl :: forall a e labels. Fn3 Metric labels a (Eff e Unit)


initCounter :: forall e. String -> String -> Array String -> Eff e Metric
initCounter name desc labels = runFn3 initCounterImpl name desc labels

incrementCounter :: forall a e . Encode a => Metric -> a -> Eff e Metric
incrementCounter counter labelRec = runFn2 incrementCounterImpl counter (encode labelRec)

incrementCounterBy :: forall a e . Encode a => Metric -> a -> Int -> Eff e Metric
incrementCounterBy counter labelRec val = runFn3 incrementCounterByImpl counter (encode labelRec) val

initHistogram :: forall e. String -> Array String -> Number -> Number -> Number -> Eff e Metric
initHistogram name labels bucketStart bucketEnd factor =
  runFn6 initHistogramImpl name name labels bucketStart bucketEnd factor

startTimer :: forall a e. Encode a => Metric -> a -> Eff e Timer
startTimer histogram labelRec  =
  runFn2 startTimerImpl histogram (encode labelRec)

endTimer :: forall a e. Encode a => Metric -> a -> Timer  -> Eff e Unit
endTimer histogram labels timer = runFn3 endTimerImpl histogram (encode labels) timer

observe :: forall a b e. Encode b => Metric -> b -> a -> Eff e Unit
observe histogram labels value = runFn3 observeImpl histogram (encode labels) value
