--------------------------------------------------------------------------------
-- |
-- Module      :  Graphics.Rendering.OpenGL.GL.Selection
-- Copyright   :  (c) Sven Panne 2003
-- License     :  BSD-style (see the file libraries/OpenGL/LICENSE)
-- 
-- Maintainer  :  sven_panne@yahoo.com
-- Stability   :  provisional
-- Portability :  portable
--
-- This module corresponds to section 5.2 (Selection) of the OpenGL 1.4 specs.
--
--------------------------------------------------------------------------------

module Graphics.Rendering.OpenGL.GL.Selection (
   HitRecord(..), getHitRecords, Name(..), pushName, loadName,
   RenderMode(..), renderMode
) where

import Control.Monad ( liftM )
import Foreign.Marshal.Array ( allocaArray )
import Foreign.Ptr ( Ptr )
import Graphics.Rendering.OpenGL.GL.BasicTypes (
   GLint, GLsizei, GLuint, GLfloat )
import Graphics.Rendering.OpenGL.GL.Exception ( finally )
import Graphics.Rendering.OpenGL.GL.IOState
import Graphics.Rendering.OpenGL.GL.RenderMode (
   RenderMode(..), withRenderMode, renderMode )

--------------------------------------------------------------------------------

data HitRecord = HitRecord GLfloat GLfloat [Name]
   deriving ( Eq, Ord, Show )

--------------------------------------------------------------------------------

getHitRecords :: GLsizei -> IO a -> IO (a, Maybe [HitRecord])
getHitRecords bufSize action =
   allocaArray (fromIntegral bufSize) $ \buf -> do
      glSelectBuffer bufSize buf
      (value, numHits) <- withRenderMode Select $ do
         glInitNames
         action
      hits <- parseSelectionBuffer numHits buf
      return (value, hits)

foreign import CALLCONV unsafe "glInitNames" glInitNames :: IO ()

foreign import CALLCONV unsafe "glSelectBuffer" glSelectBuffer ::
   GLsizei -> Ptr GLuint -> IO ()

--------------------------------------------------------------------------------

parseSelectionBuffer :: GLint -> Ptr GLuint -> IO (Maybe [HitRecord])
parseSelectionBuffer numHits buf
   | numHits < 0 = return Nothing
   | otherwise = liftM Just $ evalIOState (nTimes numHits parseSelectionHit) buf

type Parser a = IOState (Ptr GLuint) a

nTimes :: Integral a => a -> Parser b -> Parser [b]
nTimes n = sequence . replicate (fromIntegral n)

parseSelectionHit :: Parser HitRecord
parseSelectionHit = do
   nameStackDepth <- parseGLuint
   minZ <- parseGLfloat
   maxZ <- parseGLfloat
   nameStack <- nTimes nameStackDepth parseName
   return $ HitRecord minZ maxZ nameStack

parseGLuint :: Parser GLuint
parseGLuint = peekIOState

parseGLfloat :: Parser GLfloat
parseGLfloat = liftM (\x -> fromIntegral x / 0xffffffff) parseGLuint

parseName :: Parser Name
parseName = liftM Name parseGLuint

--------------------------------------------------------------------------------

newtype Name = Name GLuint
   deriving ( Eq, Ord, Show )

pushName :: Name -> IO a -> IO a
pushName name action = (do glPushName name ; action) `finally` glPopName

foreign import CALLCONV unsafe "glPopName" glPopName :: IO ()

foreign import CALLCONV unsafe "glPushName" glPushName :: Name -> IO ()

foreign import CALLCONV unsafe "glLoadName" loadName :: Name -> IO ()
