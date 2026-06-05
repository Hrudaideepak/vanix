const Profile = require('../models/profile.model');
const User = require('../models/user.model');

exports.getProfiles = async (req, res, next) => {
  try {
    const profiles = await Profile.find({ user: req.user.id });
    res.status(200).json({
      success: true,
      count: profiles.length,
      data: profiles,
    });
  } catch (error) {
    next(error);
  }
};

exports.createProfile = async (req, res, next) => {
  try {
    const { name, isKids, pin, languagePreference } = req.body;

    if (!name) {
      return res.status(400).json({ success: false, message: 'Please provide a profile name' });
    }

    const user = await User.findById(req.user.id);
    if (user.profiles.length >= 5) {
      return res.status(400).json({ success: false, message: 'Maximum limit of 5 profiles reached' });
    }

    const seed = encodeURIComponent(name);
    const avatarUrl = `https://api.dicebear.com/7.x/bottts/png?seed=${seed}`;

    const profile = await Profile.create({
      user: req.user.id,
      name,
      avatarUrl,
      isKids: !!isKids,
      pin: pin || null,
      languagePreference: languagePreference || 'en',
    });

    user.profiles.push(profile._id);
    await user.save();

    res.status(201).json({
      success: true,
      message: 'Profile created successfully',
      data: profile,
    });
  } catch (error) {
    next(error);
  }
};

exports.updateProfile = async (req, res, next) => {
  try {
    const { name, isKids, pin, languagePreference, avatarUrl } = req.body;
    let profile = await Profile.findById(req.params.id);

    if (!profile) {
      return res.status(404).json({ success: false, message: 'Profile not found' });
    }

    if (profile.user.toString() !== req.user.id) {
      return res.status(401).json({ success: false, message: 'Not authorized to modify this profile' });
    }

    if (name) profile.name = name;
    if (avatarUrl) profile.avatarUrl = avatarUrl;
    if (isKids !== undefined) profile.isKids = !!isKids;
    if (pin !== undefined) profile.pin = pin || null;
    if (languagePreference) profile.languagePreference = languagePreference;

    await profile.save();

    res.status(200).json({
      success: true,
      message: 'Profile settings updated successfully',
      data: profile,
    });
  } catch (error) {
    next(error);
  }
};

exports.deleteProfile = async (req, res, next) => {
  try {
    const profile = await Profile.findById(req.params.id);

    if (!profile) {
      return res.status(404).json({ success: false, message: 'Profile not found' });
    }

    if (profile.user.toString() !== req.user.id) {
      return res.status(401).json({ success: false, message: 'Not authorized to delete this profile' });
    }

    const user = await User.findById(req.user.id);
    user.profiles = user.profiles.filter(pId => pId.toString() !== req.params.id);
    await user.save();

    await Profile.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: 'Profile deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};
