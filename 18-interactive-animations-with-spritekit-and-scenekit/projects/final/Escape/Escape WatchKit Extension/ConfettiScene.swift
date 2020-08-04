/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SceneKit
import SpriteKit

// 1
class ConfettiScene: SCNScene {
  override init() {
    super.init()
    // 2 - Create the particle system
    let particleSystem = SCNParticleSystem()
    particleSystem.birthRate = 50
    particleSystem.emittingDirection = SCNVector3(0, 0, 1)
    particleSystem.spreadingAngle = 60
    particleSystem.particleAngle = 100
    particleSystem.particleAngleVariation = 100
    particleSystem.emitterShape = SCNPlane()
    particleSystem.particleLifeSpan = 7
    particleSystem.particleVelocity = 0.7
    particleSystem.particleVelocityVariation = 0.1
    particleSystem.particleAngularVelocity = 100
    particleSystem.particleAngularVelocityVariation = 100
    particleSystem.acceleration = SCNVector3(0, -0.001, 0)
    particleSystem.speedFactor = 1
    particleSystem.stretchFactor = 0
    particleSystem.particleColor = UIColor.red
    particleSystem.particleColorVariation = SCNVector4(1, 0.1, 0.1, 0)
    particleSystem.particleSize = 0.04
    particleSystem.particleSizeVariation = 0.001
    particleSystem.imageSequenceAnimationMode = .repeat
    particleSystem.blendMode = .alpha
    particleSystem.orientationMode = .free
    particleSystem.sortingMode = .distance
    particleSystem.isAffectedByGravity = true
    particleSystem.isAffectedByPhysicsFields = true
    particleSystem.particleMass = 0.01
    particleSystem.particleBounce = 0.7
    particleSystem.dampingFactor = 0.05
    particleSystem.loops = true
    let translationTransform = SCNMatrix4MakeTranslation(0, 1, 0)
    addParticleSystem(particleSystem, transform: translationTransform)
    // 3 - Create the turbulence field
    let turbulenceField = SCNPhysicsField.turbulenceField(smoothness: 1, animationSpeed: 1)
    turbulenceField.strength = 1.5
    rootNode.physicsField = turbulenceField
    
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 1.5)
    rootNode.addChildNode(cameraNode)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
