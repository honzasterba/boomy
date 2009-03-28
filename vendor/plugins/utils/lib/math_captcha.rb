module MathCaptcha
  
  MaxValue = 10
  MaxAnswear = 20
  Answears = 5

  def MathCaptcha.create(session, key = :capthca)
    num1 = rand MaxValue/2
    num2 = rand MaxValue/2
    session[key] = num1+num2
    res = {}
    res[:q] = "Kolik je #{num1} a #{num2}?"
    res[:a] = anwears(num1+num2)
    res
  end
  
  def MathCaptcha.check(answear, session, model, key = :capthca)
    if answear.to_i == session[key].to_i
      return nil
    else
      if model
        model.errors.add_to_base("Kontrolní otázka je zodpovězena chybně.")
      end
      return create(session, key)
    end
  end
  
  def MathCaptcha.check_and_save(answear, session, model, key = :capthca)
    model.valid?
    res = check(answear, session, model, key)
    if !res.nil?
      return res
    elsif model.save
      return nil
    else
      return create(session, key)
    end
  end
  
  def MathCaptcha.anwears(corect)
    res = []
    while res.size < rand(Answears)
      num = rand MaxAnswear
      if res.rindex(num).nil?
        res << num
      end      
    end
    if res.rindex(corect).nil?
      res << corect
    end
    res
    while res.size < Answears
      num = rand MaxAnswear
      if res.rindex(num).nil?
        res << num
      end
    end
    res
  end
  
end
