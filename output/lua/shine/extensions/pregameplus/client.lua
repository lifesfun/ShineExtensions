local Plugin = Plugin



function Plugin:Initialise()
   self.Enabled = true
end



function Plugin:Cleanup()
   self.BaseClass.Cleanup( self )
   self.Enabled = false
end


--necessary to enable the evolve button during PGP
function Plugin:Think( DeltaTime )
   if Plugin.dt.PGP_On then 
      Client.GetLocalPlayer().gameStarted = true 
   end

end