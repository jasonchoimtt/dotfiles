import Text.Pandoc.JSON
import Text.Pandoc.Walk

insertEnv :: String -> Maybe String
insertEnv ('&' : x) = Just ("\\begin{align*}" ++ x ++ "\\end{align*}")
insertEnv ('#' : x) = Just ("\\begin{equation}" ++ x ++ "\\end{equation}")
insertEnv x = Nothing

extraEquations :: Maybe Format -> Inline -> Inline
extraEquations (Just (Format fmt)) (Math DisplayMath x)
    = wrap (insertEnv x) fmt
        where wrap (Just i) "latex" = RawInline (Format "latex") i
              wrap (Just i) "html" = Math DisplayMath i -- use MathJax
              wrap _ _ = Math DisplayMath x
extraEquations _ x = x

main :: IO ()
main = toJSONFilter extraEquations
