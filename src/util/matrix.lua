-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---Returns the 4x4 matrix representing a perspective frustum
---@param fov number
---@param aspectRatio number width/height
---@param near number Usually should be 1
---@param far number Something really far out
function perspective3D(fov, aspectRatio, near, far)
    local tanHalfFov = math.tan(math.rad(fov/2))

    return 1 / (tanHalfFov * aspectRatio), 0, 0, 0,
           0, 1 / tanHalfFov, 0, 0,
           0, 0, far / (near - far), -1,
           0, 0, -((far * near) / (far - near)), 0
end

---Returns the 4x4 matrix representing a 3D translation
function translate3D(x, y, z)
    return 1, 0, 0, x,
           0, 1, 0, y,
           0, 0, 1, z,
           0, 0, 0, 1
end

---Returns the 4x4 matrix representing a 3D rotation
function rotate3D(yaw, pitch, roll)
    return math.cos(pitch)*math.cos(roll), math.sin(yaw)*math.sin(pitch)*math.cos(roll) - math.cos(yaw)*math.sin(roll), math.cos(yaw)*math.sin(pitch)*math.cos(roll) + math.sin(yaw)*math.sin(roll), 0,
           math.cos(pitch)*math.sin(roll), math.sin(yaw)*math.sin(pitch)*math.sin(roll) + math.cos(yaw)*math.cos(roll), math.cos(yaw)*math.sin(pitch)*math.sin(roll) - math.sin(yaw)*math.cos(roll), 0,
           -math.sin(pitch), math.sin(yaw)*math.cos(pitch), math.cos(yaw)*math.cos(pitch), 0,
           0, 0, 0, 1
end

---Returns the 4x4 matrix representing a 3D scaling operation
function scale3D(sx, sy, sz)
    return sx, 0, 0, 0,
           0, sy, 0, 0,
           0, 0, sz, 0,
           0, 0, 0, 1
end

---@param mat number[] A 4x4 matrix, top row first, then subsequent rows.
---@param x number
---@param y number
---@param z number
function transform3DPoint(mat, x, y, z, w)
    w = w or 1
    return mat[1]*x + mat[2]*y + mat[3]*z + mat[4]*w,
           mat[5]*x + mat[6]*y + mat[7]*z + mat[8]*w,
           mat[9]*x + mat[10]*y + mat[11]*z + mat[12]*w,
           mat[13]*x + mat[14]*y + mat[15]*z + mat[16]*w
end

return {
    perspective3D=perspective3D,
    translate3D=translate3D,
    rotate3D=rotate3D,
    scale3D=scale3D,
    transform3DPoint=transform3DPoint,
}
