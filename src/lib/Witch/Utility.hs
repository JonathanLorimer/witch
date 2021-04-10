{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}

module Witch.Utility where

import qualified Control.Exception as Exception
import qualified Control.Monad.IO.Class as IO
import qualified Data.Typeable as Typeable
import qualified GHC.Stack as Stack
import qualified Language.Haskell.TH.Syntax as TH
import qualified Witch.Cast as Cast
import qualified Witch.Identity as Identity
import qualified Witch.TryCast as TryCast
import qualified Witch.TryCastException as TryCastException

as
  :: forall s source
  . Identity.Identity s ~ source
  => source
  -> source
as = id

from
  :: forall s source target
  . (Identity.Identity s ~ source, Cast.Cast source target)
  => source
  -> target
from = Cast.cast

into
  :: forall t source target
  . (Identity.Identity t ~ target, Cast.Cast source target)
  => source
  -> target
into = Cast.cast

over
  :: forall t source target
  . (Identity.Identity t ~ target, Cast.Cast source target, Cast.Cast target source)
  => (target -> target)
  -> source
  -> source
over f = Cast.cast . f . Cast.cast

via
  :: forall u source through target
  . (Identity.Identity u ~ through, Cast.Cast source through, Cast.Cast through target)
  => source
  -> target
via = Cast.cast . (\ x -> x :: through) . Cast.cast

tryFrom
  :: forall s source target
  . (Identity.Identity s ~ source, TryCast.TryCast source target)
  => source
  -> Either (TryCastException.TryCastException source target) target
tryFrom = TryCast.tryCast

tryInto
  :: forall t source target
  . (Identity.Identity t ~ target, TryCast.TryCast source target)
  => source
  -> Either (TryCastException.TryCastException source target) target
tryInto = TryCast.tryCast

unsafeCast
  :: ( Stack.HasCallStack
  , TryCast.TryCast source target
  , Show source
  , Typeable.Typeable source
  , Typeable.Typeable target
  ) => source
  -> target
unsafeCast = either Exception.throw id . TryCast.tryCast

unsafeFrom
  :: forall s source target
  . ( Identity.Identity s ~ source
  , Stack.HasCallStack
  , TryCast.TryCast source target
  , Show source
  , Typeable.Typeable source
  , Typeable.Typeable target
  ) => source
  -> target
unsafeFrom = unsafeCast

unsafeInto
  :: forall t source target
  . ( Identity.Identity t ~ target
  , Stack.HasCallStack
  , TryCast.TryCast source target
  , Show source
  , Typeable.Typeable source
  , Typeable.Typeable target
  ) => source
  -> target
unsafeInto = unsafeCast

liftedCast
  :: ( TryCast.TryCast source target
  , TH.Lift target
  , Show source
  , Typeable.Typeable source
  , Typeable.Typeable target
  ) => source
  -> TH.Q (TH.TExp target)
liftedCast = either (IO.liftIO . Exception.throwIO) TH.liftTyped . TryCast.tryCast

liftedFrom
  :: forall s source target
  . ( Identity.Identity s ~ source
  , TryCast.TryCast source target
  , TH.Lift target
  , Show source
  , Typeable.Typeable source
  , Typeable.Typeable target
  ) => source
  -> TH.Q (TH.TExp target)
liftedFrom = liftedCast

liftedInto
  :: forall t source target
  . ( Identity.Identity t ~ target
  , TryCast.TryCast source target
  , TH.Lift target
  , Show source
  , Typeable.Typeable source
  , Typeable.Typeable target
  ) => source
  -> TH.Q (TH.TExp target)
liftedInto = liftedCast
