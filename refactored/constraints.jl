export Constraint, EqConstraint, LtConstraint, GtConstraint
export ==, <=, >=

abstract Constraint

type EqConstraint <: Constraint
  head::Symbol
  child_hash::Uint64
  lhs::AbstractExpr
  rhs::AbstractExpr
  size::(Int64, Int64)

  function EqConstraint(lhs::AbstractExpr, rhs::AbstractExpr)
    if lhs.size == rhs.size || lhs.size == (1, 1)
      sz = rhs.size
    elseif rhs.size != (1, 1)
      sz = lhs.size
    else
      error("Cannot create equality constraint between expressions of size $(lhs.size) and $(rhs.size)")
    end
    return new(:(==), hash((lhs, rhs)), lhs, rhs, sz)
  end
end

function vexity(c::EqConstraint)
  vexity = vexity(lhs) + (-vexity(rhs))
  if vexity == Convex() && vexity != Concave()
    vexity = NotDCP()
  end
  return vexity
end

function dual_conic_form(c::EqConstraint)
  expr = c.lhs - c.rhs
  objective, constraints = dual_conic_form(expr)
  new_constraint = ConicConstr(objective.vars_to_coeffs, :Zero, c.size[1] * c.size[2])
  push!(constraints, new_constraint)
  return (objective, constraints)
end

==(lhs::AbstractExpr, rhs::AbstractExpr) = EqConstraint(lhs, rhs)
==(lhs::AbstractExpr, rhs::Value) = ==(lhs, Constant(rhs))
==(lhs::Value, rhs::AbstractExpr) = ==(Constant(lhs), rhs)


