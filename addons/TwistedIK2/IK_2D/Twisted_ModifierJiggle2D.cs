using Godot;
using System;

/// <summary>
/// A modifier that runs a  simplified physics calculation on each joint to give bones a 'jiggly' movement.
/// </summary>
[Tool]
public partial class Twisted_ModifierJiggle2D : Twisted_Modifier2D
{
    /// <summary>
    /// A NodePath to the Node2D-based node that is used as the target position
    /// </summary>
    public NodePath path_to_target = null;
    /// <summary>
    /// A reference to the Node2D-based node that is used as the target position
    /// </summary>
    public Node2D target_node = null;

    /// <summary>
    /// When <c>true</c>, the Vector2 <c>target_vector</c> will be used as the target for the jiggle
    /// joint chain instead of a Node2D-based node.
    /// </summary>
    public bool use_target_vector_instead_of_node = false;
    /// <summary>
    /// A Vector2 that represents the normalized position that will be used as the target for the jiggle joint
    /// chain if <c>use_target_vector_instead_of_node</c> is <c>true</c>. Note that this vector is normalized when
    /// used and the length in the calculation is the length of all the bones in the jiggle joint chain plus 1.0.
    /// </summary>
    public Vector2 target_vector = Vector2.Zero;
    private float _target_vector_total_length = 0;

    // The position used by the jiggle joints
    private Vector2 _target_jiggle_joint_position;

    public bool make_target_vector_relative_to_node = false;
    public NodePath target_vector_relative_node_path = null;
    public Node2D target_vector_relative_node = null;

    /// <summary>
    /// The Struct used to hold all of the data for each joint in the Jiggle joint chain.
    /// </summary>
    public struct JIGGLE_JOINT {
        public NodePath path_to_twisted_bone;
        public Twisted_Bone2D twisted_bone;
        
        /// <summary>
        /// If <c>true</c>, then this joint will use its own stiffness, mass, damping, and gravity.
        /// </summary>
        public bool override_defaults;
        public float stiffness;
        public float mass;
        public float damping;
        public bool use_graivty;
        public Vector2 gravity;
        public float additional_rotation;
        public float parent_inertia;

        public Vector2 dynamic_pos;
        public Vector2 acceleration;
        public Vector2 velocity;
        public Vector2 force;
        public Vector2 last_position;
        public Vector2 last_noncollision_position;

        public JIGGLE_JOINT(NodePath path) {
            this.path_to_twisted_bone = path;
            this.twisted_bone = null;
            this.override_defaults = false;
            this.stiffness = 3;
            this.mass = 0.75f;
            this.damping = 0.75f;
            this.use_graivty = false;
            this.gravity = new Vector2(0, 6.0f);
            this.additional_rotation = 0;
            this.parent_inertia = 0.25f;

            this.dynamic_pos = Vector2.Zero;
            this.acceleration = Vector2.Zero;
            this.velocity = Vector2.Zero;
            this.force = Vector2.Zero;
            this.last_position = Vector2.Zero;
            this.last_noncollision_position = Vector2.Zero;
        }
    }
    /// <summary>
    /// All of the joints in the Jiggle chain.
    /// </summary>
    public JIGGLE_JOINT[] jiggle_joints = new JIGGLE_JOINT[0];

    public float default_stiffness = 3.0f;
    public float default_mass = 0.75f;
    public float default_damping = 0.75f;
    public bool default_use_gravity = false;
    public Vector2 default_gravity = new Vector2(0, 6.0f);
    public float default_parent_inertia = 0.25f;

    /// <summary>
    /// If <c>true</c>, then the Jiggle algorithm will use raycasting to take colliders into account.
    /// This will cause the algorithm to atempt to make sure that Jiggle joints do not rotate into collision objects.
    /// This feature only works if the modifier is set to execute in <c>_physics_process</c>.
    /// </summary>
    public bool use_colliders = false;
    /// <summary>
    /// The collision mask used in the raycasts
    /// </summary>
    public int collider_mask = 1;

    /// <summary>
    /// If <c>true</c>, the inertia motion generated by each bone in the jiggle joint chain is sent down to the
    /// next bones in the chain. This prevents extreme wiggling on the tips, as the velocity is not increasingly
    /// large as it travels down the chain.
    /// The amount of inertia passed is defined by the <c>parent_inertia</c> property, which can be set on all bones
    /// or overridden on a per-joint basis.
    /// </summary>
    public bool send_inertia_through_chain = false;
    /// <summary>
    /// If <c>true</c>, then the inertia motion will be sent through every child joint whenever its parent
    /// moves using simple physics. This is the most 'technically' correct way to pass inertia down, however
    /// it leads to the joints further in the chain being incredibly stiff, kinda negating the jiggle effect.
    /// (It's also more performance heavy!)
    /// </summary>
    public bool send_inertia_through_all_bones_in_chain = false;

    private int joint_count = 0;

    public override void _Ready()
    {
        if (path_to_target != null) {
            target_node = GetNodeOrNull<Node2D>(path_to_target);
        }
    }

    public override bool _Set(StringName property, Variant value)
    {   
        if (property == "Jiggle/target") {
            path_to_target = (NodePath)value;
            if (path_to_target != null) {
                target_node = GetNodeOrNull<Node2D>(path_to_target);
            }
            return true;
        }
        else if (property == "Jiggle/use_target_vector_instead_of_node") {
            use_target_vector_instead_of_node = (bool)value;
            calculate_target_vector_total_length();
            NotifyPropertyListChanged();
        }
        else if (property == "Jiggle/make_target_vector_relative_to_node") {
            make_target_vector_relative_to_node = (bool)value;
            NotifyPropertyListChanged();
        }
        else if (property == "Jiggle/target_vector_relative_node_path") {
            target_vector_relative_node_path = (NodePath)value;
            if (target_vector_relative_node_path != null) {
                target_vector_relative_node = GetNodeOrNull<Node2D>(target_vector_relative_node_path);
            }
        }
        else if (property == "Jiggle/target_vector") {
            target_vector = (Vector2)value;
            calculate_target_vector_total_length();

            if (target_vector.LengthSquared() == 0) {
                GD.PrintErr("ERROR - Jiggle target vector must have a non-zero length!");
            }
        }
        else if (property == "Jiggle/joint_count") {
            joint_count = (int)value;

            JIGGLE_JOINT[] new_array = new JIGGLE_JOINT[joint_count];
            for (int i = 0; i < joint_count; i++) {
                if (i < jiggle_joints.Length) {
                    new_array[i] = jiggle_joints[i];
                } else {
                    new_array[i] = new JIGGLE_JOINT(null);
                }
            }
            jiggle_joints = new_array;

            NotifyPropertyListChanged();
            return true;
        }
        else if (property == "Jiggle/use_colliders") {
            use_colliders = (bool)value;
            return true;
        }
        else if (property == "Jiggle/collider_mask") {
            collider_mask = (int)value;
            return true;
        }
        else if (property == "Jiggle/send_inertia_through_chain") {
            send_inertia_through_chain = (bool)value;
            NotifyPropertyListChanged();
            return true;
        }
        else if (property == "Jiggle/send_inertia_through_all_bones_in_chain") {
            send_inertia_through_all_bones_in_chain = (bool)value;
            NotifyPropertyListChanged();
            return true;
        }
        else if (property == "Jiggle/Default_Joint_Data/stiffness") {
            default_stiffness = (float)value;
            set_joint_data_to_defaults();
            return true;
        }
        else if (property == "Jiggle/Default_Joint_Data/mass") {
            default_mass = (float)value;
            set_joint_data_to_defaults();
            return true;
        }
        else if (property == "Jiggle/Default_Joint_Data/damping") {
            default_damping = (float)value;
            set_joint_data_to_defaults();
            return true;
        }
        else if (property == "Jiggle/Default_Joint_Data/use_gravity") {
            default_use_gravity = (bool)value;
            set_joint_data_to_defaults();
            return true;
        }
        else if (property == "Jiggle/Default_Joint_Data/gravity") {
            default_gravity = (Vector2)value;
            set_joint_data_to_defaults();
            return true;
        }
        else if (property == "Jiggle/Default_Joint_Data/parent_inertia") {
            default_parent_inertia = (float)value;
            set_joint_data_to_defaults();
            return true;
        }

        
        else if (property.ToString().StartsWith("Jiggle/joint/")) {
            String[] jiggle_data = property.ToString().Split("/");
            int joint_index = jiggle_data[2].ToInt();
            
            if (joint_index < 0 || joint_index > jiggle_joints.Length-1) {
                GD.PrintErr("ERROR - Cannot get Jiggle joint at index " + joint_index.ToString());
                return false;
            }
            JIGGLE_JOINT current_joint = jiggle_joints[joint_index];

            if (jiggle_data[3] == "twisted_bone") {
                current_joint.path_to_twisted_bone = (NodePath)value;
                if (current_joint.path_to_twisted_bone != null) {
                    current_joint.twisted_bone = GetNodeOrNull<Twisted_Bone2D>(current_joint.path_to_twisted_bone);
                }
            }
            else if (jiggle_data[3] == "override_defaults") {
                current_joint.override_defaults = (bool)value;
                
                if (current_joint.override_defaults == false) {
                    current_joint.stiffness = default_stiffness;
                    current_joint.mass = default_mass;
                    current_joint.damping = default_damping;
                    current_joint.use_graivty = default_use_gravity;
                    current_joint.gravity = default_gravity;
                    current_joint.parent_inertia = default_parent_inertia;
                }

                NotifyPropertyListChanged();
            }
            else if (jiggle_data[3] == "stiffness") {
                current_joint.stiffness = (float)value;
            }
            else if (jiggle_data[3] == "mass") {
                current_joint.mass = (float)value;
            }
            else if (jiggle_data[3] == "damping") {
                current_joint.damping = (float)value;
            }
            else if (jiggle_data[3] == "use_gravity") {
                current_joint.use_graivty = (bool)value;
            }
            else if (jiggle_data[3] == "gravity") {
                current_joint.gravity = (Vector2)value;
            }
            else if (jiggle_data[3] == "parent_inertia") {
                current_joint.parent_inertia = (float)value;
            }
            else if (jiggle_data[3] == "additional_rotation") {
                current_joint.additional_rotation = Mathf.DegToRad((float)value);
            }
            jiggle_joints[joint_index] = current_joint;

            if (use_target_vector_instead_of_node == true) {
                calculate_target_vector_total_length();
            }

            return true;
        }

        try {
            return base._Set(property, value);
        } catch {
            return false;
        }
    }

    public override Variant _Get(StringName property)
    {
        if (property == "Jiggle/target") {
            return path_to_target;
        }
        else if (property == "Jiggle/use_target_vector_instead_of_node") {
            return use_target_vector_instead_of_node;
        }
        else if (property == "Jiggle/target_vector") {
            return target_vector;
        }
        else if (property == "Jiggle/make_target_vector_relative_to_node") {
            return make_target_vector_relative_to_node;
        }
        else if (property == "Jiggle/target_vector_relative_node_path") {
            return target_vector_relative_node_path;
        }
        else if (property == "Jiggle/joint_count") {
            return joint_count;
        }
        else if (property == "Jiggle/use_colliders") {
            return use_colliders;
        }
        else if (property == "Jiggle/collider_mask") {
            return collider_mask;
        }
        else if (property == "Jiggle/send_inertia_through_chain") {
            return send_inertia_through_chain;
        }
        else if (property == "Jiggle/send_inertia_through_all_bones_in_chain") {
            return send_inertia_through_all_bones_in_chain;
        }

        else if (property == "Jiggle/Default_Joint_Data/stiffness") {
            return default_stiffness;
        }
        else if (property == "Jiggle/Default_Joint_Data/mass") {
            return default_mass;
        }
        else if (property == "Jiggle/Default_Joint_Data/damping") {
            return default_damping;
        }
        else if (property == "Jiggle/Default_Joint_Data/use_gravity") {
            return default_use_gravity;
        }
        else if (property == "Jiggle/Default_Joint_Data/gravity") {
            return default_gravity;
        }
        else if (property == "Jiggle/Default_Joint_Data/parent_inertia") {
            return default_parent_inertia;
        }

        
        else if (property.ToString().StartsWith("Jiggle/joint/")) {
            String[] jiggle_data = property.ToString().Split("/");
            int joint_index = jiggle_data[2].ToInt();

            if (jiggle_data[3] == "twisted_bone") {
                return jiggle_joints[joint_index].path_to_twisted_bone;
            }
            else if (jiggle_data[3] == "override_defaults") {
                return jiggle_joints[joint_index].override_defaults;
            }
            else if (jiggle_data[3] == "stiffness") {
                return jiggle_joints[joint_index].stiffness;
            }
            else if (jiggle_data[3] == "mass") {
                return jiggle_joints[joint_index].mass;
            }
            else if (jiggle_data[3] == "damping") {
                return jiggle_joints[joint_index].damping;
            }
            else if (jiggle_data[3] == "use_gravity") {
                return jiggle_joints[joint_index].use_graivty;
            }
            else if (jiggle_data[3] == "gravity") {
                return jiggle_joints[joint_index].gravity;
            }
            else if (jiggle_data[3] == "parent_inertia") {
                return jiggle_joints[joint_index].parent_inertia;
            }
            else if (jiggle_data[3] == "additional_rotation") {
                return Mathf.RadToDeg(jiggle_joints[joint_index].additional_rotation);
            }
        }

        return base._Get(property);
    }

    public override Godot.Collections.Array<Godot.Collections.Dictionary> _GetPropertyList()
    {
        Godot.Collections.Array<Godot.Collections.Dictionary> list = base._GetPropertyList();
        Godot.Collections.Dictionary tmp_dict;

        if (use_target_vector_instead_of_node == false) {
            tmp_dict = new Godot.Collections.Dictionary();
            tmp_dict.Add("name", "Jiggle/target");
            tmp_dict.Add("type", (int)Variant.Type.NodePath);
            tmp_dict.Add("hint", (int)PropertyHint.None);
            tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
            list.Add(tmp_dict);
        }

        tmp_dict = new Godot.Collections.Dictionary();
        tmp_dict.Add("name", "Jiggle/use_target_vector_instead_of_node");
        tmp_dict.Add("type", (int)Variant.Type.Bool);
        tmp_dict.Add("hint", (int)PropertyHint.None);
        tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
        list.Add(tmp_dict);

        if (use_target_vector_instead_of_node == true) {
            tmp_dict = new Godot.Collections.Dictionary();
            tmp_dict.Add("name", "Jiggle/target_vector");
            tmp_dict.Add("type", (int)Variant.Type.Vector2);
            tmp_dict.Add("hint", (int)PropertyHint.None);
            tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
            list.Add(tmp_dict);

            tmp_dict = new Godot.Collections.Dictionary();
            tmp_dict.Add("name", "Jiggle/make_target_vector_relative_to_node");
            tmp_dict.Add("type", (int)Variant.Type.Bool);
            tmp_dict.Add("hint", (int)PropertyHint.None);
            tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
            list.Add(tmp_dict);

            if (make_target_vector_relative_to_node == true) {
                tmp_dict = new Godot.Collections.Dictionary();
                tmp_dict.Add("name", "Jiggle/target_vector_relative_node_path");
                tmp_dict.Add("type", (int)Variant.Type.NodePath);
                tmp_dict.Add("hint", (int)PropertyHint.None);
                tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
                list.Add(tmp_dict);
            }
        }

        tmp_dict = new Godot.Collections.Dictionary();
        tmp_dict.Add("name", "Jiggle/joint_count");
        tmp_dict.Add("type", (int)Variant.Type.Int);
        tmp_dict.Add("hint", (int)PropertyHint.None);
        tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
        list.Add(tmp_dict);

        if (execution_mode == TWISTED_IK_MODIFIER_MODES_2D._PHYSICS_PROCESS) {
            tmp_dict = new Godot.Collections.Dictionary();
            tmp_dict.Add("name", "Jiggle/use_colliders");
            tmp_dict.Add("type", (int)Variant.Type.Bool);
            tmp_dict.Add("hint", (int)PropertyHint.None);
            tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
            list.Add(tmp_dict);

            tmp_dict = new Godot.Collections.Dictionary();
            tmp_dict.Add("name", "Jiggle/collider_mask");
            tmp_dict.Add("type", (int)Variant.Type.Int);
            tmp_dict.Add("hint", (int)PropertyHint.Layers2DPhysics);
            tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
            list.Add(tmp_dict);
        }

        tmp_dict = new Godot.Collections.Dictionary();
        tmp_dict.Add("name", "Jiggle/send_inertia_through_chain");
        tmp_dict.Add("type", (int)Variant.Type.Bool);
        tmp_dict.Add("hint", (int)PropertyHint.None);
        tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
        list.Add(tmp_dict);

        if (send_inertia_through_chain == true) {
            tmp_dict = new Godot.Collections.Dictionary();
            tmp_dict.Add("name", "Jiggle/send_inertia_through_all_bones_in_chain");
            tmp_dict.Add("type", (int)Variant.Type.Bool);
            tmp_dict.Add("hint", (int)PropertyHint.None);
            tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
            list.Add(tmp_dict);
        }

        // Default joint data
        // ===================
        tmp_dict = new Godot.Collections.Dictionary();
        tmp_dict.Add("name", "Jiggle/Default_Joint_Data/stiffness");
        tmp_dict.Add("type", (int)Variant.Type.Float);
        tmp_dict.Add("hint", (int)PropertyHint.None);
        tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
        list.Add(tmp_dict);

        tmp_dict = new Godot.Collections.Dictionary();
        tmp_dict.Add("name", "Jiggle/Default_Joint_Data/mass");
        tmp_dict.Add("type", (int)Variant.Type.Float);
        tmp_dict.Add("hint", (int)PropertyHint.None);
        tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
        list.Add(tmp_dict);

        tmp_dict = new Godot.Collections.Dictionary();
        tmp_dict.Add("name", "Jiggle/Default_Joint_Data/damping");
        tmp_dict.Add("type", (int)Variant.Type.Float);
        tmp_dict.Add("hint", (int)PropertyHint.None);
        tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
        list.Add(tmp_dict);

        tmp_dict = new Godot.Collections.Dictionary();
        tmp_dict.Add("name", "Jiggle/Default_Joint_Data/use_gravity");
        tmp_dict.Add("type", (int)Variant.Type.Bool);
        tmp_dict.Add("hint", (int)PropertyHint.None);
        tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
        list.Add(tmp_dict);

        tmp_dict = new Godot.Collections.Dictionary();
        tmp_dict.Add("name", "Jiggle/Default_Joint_Data/gravity");
        tmp_dict.Add("type", (int)Variant.Type.Vector2);
        tmp_dict.Add("hint", (int)PropertyHint.None);
        tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
        list.Add(tmp_dict);

        if (send_inertia_through_chain == true) {
            tmp_dict = new Godot.Collections.Dictionary();
            tmp_dict.Add("name", "Jiggle/Default_Joint_Data/parent_inertia");
            tmp_dict.Add("type", (int)Variant.Type.Float);
            tmp_dict.Add("hint", (int)PropertyHint.None);
            tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
            list.Add(tmp_dict);
        }

        // ===================

        // The Jiggle Joints
        // ===================
        String jiggle_string = "Jiggle/joint/";
        for (int i = 0; i < joint_count; i++) {
            tmp_dict = new Godot.Collections.Dictionary();
            tmp_dict.Add("name", jiggle_string + i.ToString() + "/twisted_bone");
            tmp_dict.Add("type", (int)Variant.Type.NodePath);
            tmp_dict.Add("hint", (int)PropertyHint.None);
            tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
            list.Add(tmp_dict);

            tmp_dict = new Godot.Collections.Dictionary();
            tmp_dict.Add("name", jiggle_string + i.ToString() + "/override_defaults");
            tmp_dict.Add("type", (int)Variant.Type.Bool);
            tmp_dict.Add("hint", (int)PropertyHint.None);
            tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
            list.Add(tmp_dict);

            if (jiggle_joints[i].override_defaults == true) {
                tmp_dict = new Godot.Collections.Dictionary();
                tmp_dict.Add("name", jiggle_string + i.ToString() + "/stiffness");
                tmp_dict.Add("type", (int)Variant.Type.Float);
                tmp_dict.Add("hint", (int)PropertyHint.None);
                tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
                list.Add(tmp_dict);

                tmp_dict = new Godot.Collections.Dictionary();
                tmp_dict.Add("name", jiggle_string + i.ToString() + "/mass");
                tmp_dict.Add("type", (int)Variant.Type.Float);
                tmp_dict.Add("hint", (int)PropertyHint.None);
                tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
                list.Add(tmp_dict);

                tmp_dict = new Godot.Collections.Dictionary();
                tmp_dict.Add("name", jiggle_string + i.ToString() + "/damping");
                tmp_dict.Add("type", (int)Variant.Type.Float);
                tmp_dict.Add("hint", (int)PropertyHint.None);
                tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
                list.Add(tmp_dict);

                tmp_dict = new Godot.Collections.Dictionary();
                tmp_dict.Add("name", jiggle_string + i.ToString() + "/use_gravity");
                tmp_dict.Add("type", (int)Variant.Type.Bool);
                tmp_dict.Add("hint", (int)PropertyHint.None);
                tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
                list.Add(tmp_dict);

                tmp_dict = new Godot.Collections.Dictionary();
                tmp_dict.Add("name", jiggle_string + i.ToString() + "/gravity");
                tmp_dict.Add("type", (int)Variant.Type.Vector2);
                tmp_dict.Add("hint", (int)PropertyHint.None);
                tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
                list.Add(tmp_dict);

                if (send_inertia_through_chain == true) {
                    tmp_dict = new Godot.Collections.Dictionary();
                    tmp_dict.Add("name", jiggle_string + i.ToString() + "/parent_inertia");
                    tmp_dict.Add("type", (int)Variant.Type.Float);
                    tmp_dict.Add("hint", (int)PropertyHint.None);
                    tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
                    list.Add(tmp_dict);
                }
            }

            tmp_dict = new Godot.Collections.Dictionary();
            tmp_dict.Add("name", jiggle_string + i.ToString() + "/additional_rotation");
            tmp_dict.Add("type", (int)Variant.Type.Float);
            tmp_dict.Add("hint", (int)PropertyHint.None);
            tmp_dict.Add("usage", (int)PropertyUsageFlags.Default);
            list.Add(tmp_dict);
        }

        return list;
    }

    private void set_joint_data_to_defaults() {
        for (int i = 0; i < jiggle_joints.Length; i++) {
            JIGGLE_JOINT current_joint = jiggle_joints[i];
            if (current_joint.override_defaults == false) {
                current_joint.stiffness = default_stiffness;
                current_joint.mass = default_mass;
                current_joint.damping = default_damping;
                current_joint.use_graivty = default_use_gravity;
                current_joint.gravity = default_gravity;
                current_joint.parent_inertia = default_parent_inertia;
                jiggle_joints[i] = current_joint;
            }
        }
    }

    public override void _ExecuteModification(Twisted_ModifierStack2D modifier_stack, double delta)
    {
        base._ExecuteModification(modifier_stack, delta);

        if (use_target_vector_instead_of_node == false) {
            if (target_node == null) {
                // Try to get the target
                if (path_to_target != null) {
                    target_node = GetNodeOrNull<Node2D>(path_to_target);
                    if (target_node == null) {
                        GD.PrintErr("Cannot execute Jiggle 2D: No target found!");
                        return;
                    }
                }
                else {
                    GD.PrintErr("Cannot execute Jiggle 2D: No target found and/or nodepath to target is not setup!");
                    return;
                }
            }
        }
        else {
            if (target_vector.LengthSquared() == 0) {
                GD.PrintErr("Cannot execute Jiggle 2D: Jiggle target vector must be more than zero!");
                return;
            }
        }

        if (jiggle_joints.Length <= 0) {
            GD.PrintErr("Cannot execute Jiggle 2D: No Jiggle joints found!");
            return;
        }

        if (use_target_vector_instead_of_node == false) {
            _target_jiggle_joint_position = Twisted_2DFunctions.world_transform_to_global_pose(
                target_node.GlobalTransform, modifier_stack.skeleton).Origin;
        } else {
            if (_target_vector_total_length == 0) {
                calculate_target_vector_total_length();
            }

            Vector2 target_origin_position = target_vector;
            Vector2 target_vector_direction = target_vector;

            // Make the position relative to the first bone in the chain
            if (jiggle_joints.Length > 0) {
                if (jiggle_joints[0].twisted_bone != null) {
                    target_origin_position = Twisted_2DFunctions.world_transform_to_global_pose(
                        jiggle_joints[0].twisted_bone.GlobalTransform, modifier_stack.skeleton).Origin;
                }
            }

            // Make the vector relative to a node?
            if (make_target_vector_relative_to_node == true) {
                if (target_vector_relative_node == null) {
                    if (target_vector_relative_node_path != null) {
                        target_vector_relative_node = GetNodeOrNull<Node2D>(target_vector_relative_node_path);
                    }
                    if (target_vector_relative_node == null) {
                        GD.PrintErr("Cannot execute Jiggle: Cannot get relative target vector node!");
                        return;
                    }
                }
                Transform2D relative_node_trans = Twisted_2DFunctions.world_transform_to_global_pose(target_vector_relative_node.GlobalTransform, modifier_stack.skeleton);
                target_vector_direction = target_vector_direction.Rotated(relative_node_trans.Rotation);
            }

            _target_jiggle_joint_position = target_origin_position + (target_vector_direction.Normalized() * _target_vector_total_length);
        }

        for (int i = 0; i < jiggle_joints.Length; i++) {
            _ExecuteJoint(i, modifier_stack, delta);
        }
    }


    private void _ExecuteJoint(int joint_id, Twisted_ModifierStack2D modifier_stack, double delta) {
        JIGGLE_JOINT current_joint = jiggle_joints[joint_id];
        if (current_joint.twisted_bone == null) {
            current_joint.twisted_bone = GetNodeOrNull<Twisted_Bone2D>(current_joint.path_to_twisted_bone);
            if (current_joint.twisted_bone == null) {
                GD.PrintErr("Cannot find TwistedBone2D for joint: " + joint_id.ToString() + ". ABORTING IK!");
                return;
            }
        }

        Transform2D twisted_transform = Twisted_2DFunctions.world_transform_to_global_pose(current_joint.twisted_bone.GlobalTransform, modifier_stack.skeleton);

        current_joint.force = (_target_jiggle_joint_position - current_joint.dynamic_pos) * current_joint.stiffness * (float)delta;

        if (current_joint.use_graivty == true) {
            Vector2 gravity_to_apply;
            if (modifier_stack.skeleton != null) {
                gravity_to_apply = current_joint.gravity.Rotated(-modifier_stack.skeleton.GlobalRotation);
            }
            else {
                // TODO: print a warning that the gravity may not point in the correct direction!
                gravity_to_apply = current_joint.gravity.Rotated(-twisted_transform.Rotation);
            }
            current_joint.force += gravity_to_apply * (float)delta;
        }

        current_joint.acceleration = current_joint.force * current_joint.mass;

        Vector2 last_velocity = current_joint.velocity;
        current_joint.velocity += current_joint.acceleration * (1 - current_joint.damping);

        current_joint.dynamic_pos += current_joint.velocity + current_joint.force;
        current_joint.dynamic_pos += twisted_transform.Origin - current_joint.last_position;
        current_joint.last_position = twisted_transform.Origin;

        Transform2D dynamic_trans_in_world = new Transform2D(0, current_joint.dynamic_pos);
        dynamic_trans_in_world = Twisted_2DFunctions.global_pose_to_world_transform(dynamic_trans_in_world, modifier_stack.skeleton);

        if (use_colliders == true && execution_mode == TWISTED_IK_MODIFIER_MODES_2D._PHYSICS_PROCESS) {
            World2D world_2d = GetWorld2D();
            PhysicsDirectSpaceState2D space_state = world_2d.DirectSpaceState;
            
            PhysicsRayQueryParameters2D ray_params = new PhysicsRayQueryParameters2D();
            ray_params.From = current_joint.twisted_bone.GlobalTransform.Origin;
            ray_params.To = dynamic_trans_in_world.Origin;
            ray_params.CollisionMask = (uint)collider_mask;
            ray_params.CollideWithBodies = true;
            ray_params.CollideWithAreas = false;

            Godot.Collections.Dictionary result = space_state.IntersectRay(ray_params);
            
            if (result.Count > 0) {
                current_joint.dynamic_pos = current_joint.last_noncollision_position;
                current_joint.acceleration = Vector2.Zero;
                current_joint.velocity = Vector2.Zero;
                current_joint.force = Vector2.Zero;
            } else {
                current_joint.last_noncollision_position = current_joint.dynamic_pos;
            }
        }

        // Rotate the bone to look at the new position
        Vector2 tmp_scale = current_joint.twisted_bone.Scale;

        current_joint.twisted_bone.set_executing_ik(true);
        current_joint.twisted_bone.LookAt(dynamic_trans_in_world.Origin);
        current_joint.twisted_bone.Rotate(current_joint.additional_rotation);
        current_joint.twisted_bone.Rotate(-current_joint.twisted_bone.bone_angle);

        // Adjust for scale
        current_joint.twisted_bone.Scale = tmp_scale;

        jiggle_joints[joint_id] = current_joint;

        if (send_inertia_through_chain == true) {
            for (int j = joint_id+1; j < jiggle_joints.Length; j++) {
                JIGGLE_JOINT child_joint = jiggle_joints[j];
                
                if (child_joint.twisted_bone == null) {
                    child_joint.twisted_bone = GetNodeOrNull<Twisted_Bone2D>(child_joint.path_to_twisted_bone);
                    if (child_joint.twisted_bone == null) {
                        continue;
                    }
                }

                float distance_to_remove = (current_joint.velocity - last_velocity).Length();
                child_joint.velocity -= (child_joint.velocity.Normalized() * distance_to_remove) * child_joint.parent_inertia;
                child_joint.dynamic_pos -= (child_joint.velocity.Normalized() * distance_to_remove) * child_joint.parent_inertia;
                jiggle_joints[j] = child_joint;

                if (send_inertia_through_all_bones_in_chain == false) {
                    break;
                }
            }
        }
    }

    private void calculate_target_vector_total_length() {
        float total_length = 0;
        for (int i = 0; i < jiggle_joints.Length; i++) {
            if (jiggle_joints[i].twisted_bone != null) {
                total_length += jiggle_joints[i].twisted_bone.bone_length;
            }
        }
        _target_vector_total_length = total_length + 1.0f;
    }
}