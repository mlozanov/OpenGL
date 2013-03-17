--------------------------------------------------------------------------------
-- |
-- Module      :  Graphics.Rendering.OpenGL.GL.Bitmaps
-- Copyright   :  (c) Sven Panne 2002-2009
-- License     :  BSD-style (see the file libraries/OpenGL/LICENSE)
-- 
-- Maintainer  :  sven.panne@aedion.de
-- Stability   :  stable
-- Portability :  portable
--
-- This module corresponds to section 3.7 (Bitmaps) of the OpenGL 2.1 specs.
--
--------------------------------------------------------------------------------

module Graphics.Rendering.OpenGL.GL.Bitmaps (
   bitmap
) where

import Foreign.Ptr
import Graphics.Rendering.OpenGL.Raw.Core31
import Graphics.Rendering.OpenGL.Raw.ARB.Compatibility ( glBitmap )
import Graphics.Rendering.OpenGL.GL.CoordTrans
import Graphics.Rendering.OpenGL.GL.Tensor

--------------------------------------------------------------------------------

bitmap :: Size -> (Vertex2 GLfloat) -> (Vector2 GLfloat) -> Ptr GLubyte -> IO ()
bitmap (Size w h) (Vertex2 xbo ybo) (Vector2 xbi ybi) =
   glBitmap w h xbo ybo xbi ybi
