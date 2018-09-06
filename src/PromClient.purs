module PromClient where

import Prelude
import Data.Function.Uncurried (Fn2, Fn3, runFn2, runFn3)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Aff (Aff)
import Data.Foreign.Class (class Encode, encode)
import Node.Express.Types (ExpressM, Response, Request)

foreign import data Metric :: Type
foreign import data Timer :: Type
foreign import promClusterMetrics :: forall e. Fn3 Request Response (ExpressM e Unit) (ExpressM e Unit)
foreign import promMetricsHandler :: forall e. Fn3 Request Response (ExpressM e Unit) (ExpressM e Unit)

foreign import initCounter' :: forall e. Fn3 String String (Array String) (Eff e Metric)
foreign import incrementCounter' :: forall a e. Fn2 Metric a (Eff e Metric)

initCounter :: forall e. String -> String -> Array String -> Eff e Metric
initCounter name desc labels =
  runFn3 initCounter' name desc labels

incrementCounter :: forall a e . Encode a => Metric -> a -> Aff e Metric
incrementCounter counter labelRec = do
  liftEff $ runFn2 incrementCounter' counter (encode labelRec)